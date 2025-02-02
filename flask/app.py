from flask import Flask, request, jsonify
import os
from recognize import describe_image

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)  # Ensure the folder exists
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file uploaded'}), 400

    file = request.files['image']
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
    file.save(file_path)
    response = describe_image(file_path)
    

    return jsonify({'message': 'Search term generated', 'term': response})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
