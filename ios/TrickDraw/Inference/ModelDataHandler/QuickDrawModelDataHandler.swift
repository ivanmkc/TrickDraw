//
//  QuickDrawModelDataHandler.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-15.
//  Copyright © 2020 Google. All rights reserved.
//

import TensorFlowLite

/// Define errors that could happen in when doing image clasification
enum ClassificationError: Error {
    // Invalid input image
    case invalidImage
    // TF Lite Internal Error when initializing
    case internalError(Error)
    case invalidOutput
}

struct InferenceResult {
    let guess: String
    let confidence: Float
}

/// This class handles all data preprocessing and makes calls to perform inference on a given image
/// by invoking the `Interpreter`.
class QuickDrawModelDataHandler: ModelDataHandling {
    typealias Input = UIImage
    typealias Inference = [InferenceResult]
    
    static let shared = QuickDrawModelDataHandler()! // TODO: Use DI
    
    // TODO
    lazy var labels: [String]? = {
        guard let labelPath = Bundle.main.path(forResource: labelFileInfo.name,
                                               ofType: labelFileInfo.extension) else { return nil}
        let fileContents = try? String(contentsOfFile: labelPath)
        guard let labels = fileContents?.components(separatedBy: "\n") else { return nil }

        return labels.filter { !$0.isEmpty }
    }()
    
    /// Information about the MobileNet model.
    enum Model {
        static let modelInfo: FileInfo = (name: "models/10_500/model", extension: "tflite")
        //      static let modelInfoQuantized: FileInfo = (name: "style_predict_quantized_256", extension: "tflite")
        static let labelInfo: FileInfo = (name: "models/10_500/dict", extension: "txt")
        static let inputImageWidth: Int = 224
        static let inputImageHeight: Int = 224
    }
    
    // MARK: - Internal Properties
    
    let threadCount: Int
    let threadCountLimit = 10
    
    // MARK: - Private Properties
    /// TensorFlow Lite `Interpreter` object for performing inference on a given model.
    private var interpreter: Interpreter
    
    private let modelFileInfo = Model.modelInfo
    private let labelFileInfo = Model.labelInfo
    
    // MARK: - Initialization
    
    /// A failable initializer for `ModelDataHandler`. A new instance is created if the model and
    /// labels files are successfully loaded from the app's main bundle. Default `threadCount` is 1.
    init?(threadCount: Int = 1) {
        // Construct the path to the model file.
        guard let modelPath = Bundle.main.path(
            forResource: modelFileInfo.name,
            ofType: modelFileInfo.extension
            ) else {
                print("Failed to load the model file with name: \(modelFileInfo.name).")
                return nil
        }
        
        // Specify the options for the `Interpreter`.
        self.threadCount = threadCount
        var options = Interpreter.Options()
        options.threadCount = threadCount
        do {
            // Create the `Interpreter`.
            interpreter = try Interpreter(modelPath: modelPath, options: options)
            
            // Allocate memory for the model's input `Tensor`s.
            try interpreter.allocateTensors()
            
//            for tensorIndex in 0..<interpreter.inputTensorCount {
//                print("\(tensorIndex): \(try interpreter.input(at: tensorIndex).shape)")
//            }
        } catch let error {
            print("Failed to create the interpreter with error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // MARK: - Internal Methods
    /// Performs image preprocessing, invokes the `Interpreter`, and processes the inference results.
    func runModel(input: UIImage) -> Result<[InferenceResult], Error> {
        let outputTensor: Tensor
        do {
            // Get the output `Tensor` to process the inference results.
            let inputTensor = try self.interpreter.input(at: 0)
            
            // Preprocessing: Convert the input UIImage to RGB image to feed to TF Lite model.
            guard let rgbData = input.pixelData(size: CGSize(width: inputTensor.shape.dimensions[1],
                                                             height: inputTensor.shape.dimensions[2]))
                else {
                    print("Failed to convert the image buffer to RGB data.")

                    return .failure(ClassificationError.invalidImage)
            }
            
            // Copy the RGB data to the input `Tensor`.
            try self.interpreter.copy(rgbData, toInputAt: 0)
            
            // Run inference by invoking the `Interpreter`.
            try self.interpreter.invoke()
            
            // Get the output `Tensor` to process the inference results.
            outputTensor = try self.interpreter.output(at: 0)
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
            return .failure(ClassificationError.internalError(error))
        }
        
        // Copy output to `Data` to process the inference results.
        let outputSize = outputTensor.shape.dimensions.reduce(1, {x, y in x * y})
        let outputData =
              UnsafeMutableBufferPointer<UInt8>.allocate(capacity: outputSize)
        outputTensor.data.copyBytes(to: outputData)

        let scale = outputTensor.quantizationParameters?.scale ?? 1
        let zeroPoint = outputTensor.quantizationParameters?.zeroPoint ?? 0
        let adjustedData = outputData.map { scale * (Float($0) - Float(zeroPoint)) }
        
//        print("Results:")
//        adjustedData.enumerated().forEach{ print("\t\($0)") }
        
//        let maxResult = adjustedData
//            .enumerated()
//            .max { $0.element <= $1.element }
//        
//        let maxOffset = maxResult?.offset ?? 0
        
        if let labels = labels {
            return .success(zip(labels, adjustedData)
                                .map { InferenceResult(guess: $0, confidence: $1) }
                                .sorted(by: { $0.confidence > $1.confidence }))
        } else {
            return .failure(ClassificationError.invalidOutput)
        }
    }
}
