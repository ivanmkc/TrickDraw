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
}

/// This class handles all data preprocessing and makes calls to perform inference on a given image
/// by invoking the `Interpreter`.
class QuickDrawModelDataHandler: ModelDataHandling {
    
    typealias Input = UIImage
    typealias Inference = Int
    
    
    /// Information about the MobileNet model.
    enum Model {
        static let modelInfo: FileInfo = (name: "tflite-m_350_classes_300/model", extension: "tflite")
        //      static let modelInfoQuantized: FileInfo = (name: "style_predict_quantized_256", extension: "tflite")
        static let inputImageWidth: Int = 256
        static let inputImageHeight: Int = 256
    }
    
    // MARK: - Internal Properties
    
    let threadCount: Int
    let threadCountLimit = 10
    
    // MARK: - Private Properties
    /// TensorFlow Lite `Interpreter` object for performing inference on a given model.
    private var interpreter: Interpreter
    
    private let modelFileInfo = Model.modelInfo
    
    // MARK: - Initialization
    
    /// A failable initializer for `ModelDataHandler`. A new instance is created if the model and
    /// labels files are successfully loaded from the app's main bundle. Default `threadCount` is 1.
    init?(threadCount: Int = 1) {
        let modelFilename = modelFileInfo.name
        
        // Construct the path to the model file.
        guard let modelPath = Bundle.main.path(
            forResource: modelFilename,
            ofType: modelFileInfo.extension
            ) else {
                print("Failed to load the model file with name: \(modelFilename).")
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
            
            for tensorIndex in 0..<interpreter.inputTensorCount {
                print("\(tensorIndex): \(try interpreter.input(at: tensorIndex).shape)")
            }
        } catch let error {
            print("Failed to create the interpreter with error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // MARK: - Internal Methods
    /// Performs image preprocessing, invokes the `Interpreter`, and processes the inference results.
    func runModel(input: UIImage) -> Result<Int, Error>? {
        let outputTensor: Tensor
        do {
            // Preprocessing: Convert the input UIImage to (28 x 28) grayscale image to feed to TF Lite model.
            guard let rgbData = input.scaledData(with: CGSize(
                width: Model.inputImageWidth,
                height: Model.inputImageHeight))
                else {
                    //              DispatchQueue.main.async {
                    //                completion(.error(ClassificationError.invalidImage))
                    
                    //              }
                    
                    return .failure(ClassificationError.invalidImage)
                    print("Failed to convert the image buffer to RGB data.")
            }
            
            // Allocate memory for the model's input `Tensor`s.
            try self.interpreter.allocateTensors()
            
            // Copy the RGB data to the input `Tensor`.
            try self.interpreter.copy(rgbData, toInputAt: 0)
            
            // Run inference by invoking the `Interpreter`.
            try self.interpreter.invoke()
            
            // Get the output `Tensor` to process the inference results.
            outputTensor = try self.interpreter.output(at: 0)
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
//            DispatchQueue.main.async {
//                completion(.error(ClassificationError.internalError(error)))
//            }
            return .failure(ClassificationError.internalError(error))
        }
        
        // Postprocessing: Find the label with highest confidence and return as human readable text.
        let results = outputTensor.data.toArray(type: Float32.self)
        let maxConfidence = results.max() ?? -1
        let maxIndex = results.firstIndex(of: maxConfidence) ?? -1
        let humanReadableResult = "Predicted: \(maxIndex)\nConfidence: \(maxConfidence)"
        
        return .success(maxIndex)
    }
}
