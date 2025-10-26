import 'package:tflite_flutter/tflite_flutter.dart';

class TensorflowService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      // TODO: Make sure you have placed your model in the assets folder
      // and updated pubspec.yaml accordingly.
      _interpreter = await Interpreter.fromAsset('model.tflite');
      print('TensorFlow Lite model loaded successfully.');
    } catch (e) {
      print('Failed to load TensorFlow Lite model: $e');
    }
  }

  String predict(List<double> inputData) {
    if (_interpreter == null) {
      return "Model not loaded";
    }

    // TODO: This is a placeholder. You MUST customize the input and output
    // shapes and data types to match your specific model.
    
    // Example: Assuming model takes a 1x10 input and returns a 1x2 output
    // The input shape should be [1, number_of_features]
    var input = [inputData]; 
    
    // The output shape should be [1, number_of_classes]
    var output = List.filled(1 * 2, 0).reshape([1, 2]);

    try {
      _interpreter!.run(input, output);

      // TODO: Process the output according to your model's logic.
      // This example assumes the output is a list of probabilities and
      // we are picking the one with the highest score.
      if (output[0][0] > output[0][1]) {
        return "Class A";
      } else {
        return "Class B";
      }
    } catch (e) {
      print("Failed to run model inference: $e");
      return "Error in prediction";
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
