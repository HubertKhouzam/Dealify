import openai
import base64
import os
from pathlib import Path

# Initialize OpenAI client
client = openai.OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

def describe_image(image_path):
    try:
        if not Path(image_path).is_file():
            raise FileNotFoundError(f"Image file {image_path} not found")

        with open(image_path, "rb") as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode("utf-8")
        
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "system", 
                    "content": "You are an AI that extracts product names from labels."
                },
                {
                    "role": "user", 
                    "content": [
                        {
                            "type": "text", 
                            "text": "Extract the product name from the label. No punctuation. Only the product name. In lowercase. I don't want any abbreviations. For example a label with gr. apple should be green apple "
                        },
                        {
                            "type": "image_url",
                            "image_url": { 
                                "url": f"data:image/jpeg;base64,{encoded_image}",
                                "detail": "high"
                            }
                        }
                    ]
                }
            ],
            max_tokens=10,
            temperature=0.1
        )
        
        return response.choices[0].message.content.strip(' ."')
    
    except Exception as e:
        print(f"Error processing image: {str(e)}")
        return None

if __name__ == "__main__":
    image_path = "example1.jpg"
    description = describe_image(image_path)
    if description:
        print(description)