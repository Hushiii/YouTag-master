from flask import Flask, request, jsonify
from yt_dlp import YoutubeDL

app = Flask(__name__)

@app.route("/api/yt-audio", methods=["POST"])
def extract_audio():
    url = request.json.get("url")
    if not url:
        return jsonify({"error": "Missing URL"}), 400

    # 将其他格式转换为真正的 m4a (AAC) 的音频格式
    ydl_opts = {
        "format": "bestaudio[ext=m4a]/bestaudio/best",
        "quiet": True,
        "skip_download": True,
        "forcejson": True
    }

    try:
        with YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            return jsonify({
                "title": info.get("title"),
                "duration": info.get("duration"),
                "audio_url": info["url"],
                "thumbnail": info.get("thumbnail")
            })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050)
