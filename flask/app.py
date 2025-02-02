from flask import Flask, request, jsonify
import os
from recognize import describe_image
import nltk
from nltk.tokenize import word_tokenize
from rank_bm25 import BM25Okapi
import pandas as pd



app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)  # Ensure the folder exists
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file uploaded'}), 400

    print('Processing request')
    file = request.files['image']
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
    file.save(file_path)
    response = describe_image(file_path)
    print(response)
    tokenized_query = word_tokenize(response.lower())
    scores = bm25.get_scores(tokenized_query)
    top_indices = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)[:10]
    results = [
        {
            "rank": rank + 1,
            "text": items[idx],
            "price": df.loc[df['name'] == items[idx], 'price'].values[0] if not df.loc[df['name'] == items[idx], 'price'].empty else None,
            "store": df.loc[df['name'] == items[idx], 'store'].values[0] if not df.loc[df['name'] == items[idx], 'store'].empty else None
        }
        for rank, idx in enumerate(top_indices)]
    return jsonify(results)

# Semantic search
nltk.download("punkt_tab", quiet=True)
nltk.download("punkt", quiet=True)
df = pd.read_csv("supermarkets.csv")
items = df['name'].astype(str).tolist()
tokenized_corpus = [word_tokenize(doc.lower()) for doc in items]
bm25 = BM25Okapi(tokenized_corpus)

@app.route('/search/<string:query>', methods=['GET'])
def search_bm25(query):
    if not query:
        return jsonify({"error": "Query parameter is required"}), 400
    
    print('Processing: ' + query)
    tokenized_query = word_tokenize(query.lower())
    scores = bm25.get_scores(tokenized_query)
    top_indices = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)[:10]
    results = [
        {
            "rank": rank + 1,
            "text": items[idx],
            "price": df.loc[df['name'] == items[idx], 'price'].values[0] if not df.loc[df['name'] == items[idx], 'price'].empty else None,
            "store": df.loc[df['name'] == items[idx], 'store'].values[0] if not df.loc[df['name'] == items[idx], 'store'].empty else None
        }
        for rank, idx in enumerate(top_indices)]

    
    return jsonify(results)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
