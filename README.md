<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SLTB Asset Management & Survey App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background-color: #f4f6f8;
            color: #333;
        }
        header {
            background-color: #0d47a1;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            width: 85%;
            margin: auto;
            padding: 20px;
        }
        h2 {
            color: #0d47a1;
            margin-top: 30px;
        }
        ul {
            line-height: 1.8;
        }
        .card {
            background: white;
            padding: 20px;
            margin-top: 15px;
            border-radius: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }
        footer {
            text-align: center;
            padding: 15px;
            background: #0d47a1;
            color: white;
            margin-top: 30px;
        }
    </style>
</head>
<body>

<header>
    <h1>🚌 SLTB Asset Management & Survey App</h1>
    <p>Digital solution for managing and monitoring SLTB assets</p>
</header>

<div class="container">

    <div class="card">
        <p>
            A modern mobile application developed for the Sri Lanka Transport Board (SLTB) 
            to digitally manage, inspect, and monitor the condition of buses and other physical assets. 
            Built using Flutter and powered by Firebase for real-time data handling and secure operations.
        </p>
    </div>

    <h2>🌟 Key Features</h2>
    <div class="card">
        <ul>
            <li><b>User Authentication:</b> Secure login and registration using Firebase Authentication.</li>
            <li><b>Interactive Dashboard:</b> Real-time statistics of working and faulty assets.</li>
            <li><b>Asset Surveying:</b> Record asset conditions (Working, Faulty, Under Repair).</li>
            <li><b>Photo Evidence:</b> Capture images or upload from gallery as proof.</li>
            <li><b>Dark Mode & Theming:</b> Supports Light/Dark mode using Provider.</li>
            <li><b>Multi-language Support:</b> English and Sinhala UI support.</li>
            <li><b>Secure Settings:</b> Password reset and account management.</li>
        </ul>
    </div>

    <h2>🛠️ Technology Stack</h2>
    <div class="card">
        <ul>
            <li><b>Frontend:</b> Flutter & Dart</li>
            <li><b>Backend:</b> Firebase (Authentication & Cloud Firestore)</li>
            <li><b>State Management:</b> Provider</li>
            <li><b>Device Features:</b> Image Picker (Camera & Gallery)</li>
        </ul>
    </div>

    <h2>🚀 Getting Started</h2>
    <div class="card">
        <p>Follow these steps to run the project locally:</p>
        <ol>
            <li>Clone the repository</li>
            <li>Open project folder</li>
            <li>Run <code>flutter pub get</code></li>
            <li>Run <code>flutter run</code></li>
        </ol>
    </div>

    <h2>📌 Prerequisites</h2>
    <div class="card">
        <ul>
            <li>Flutter SDK (v3.10.7 or higher)</li>
            <li>Android Studio / VS Code</li>
            <li>Firebase Project</li>
        </ul>
    </div>

</div>

<footer>
    <p>© 2026 SLTB Survey App | Developed for Educational Purposes</p>
</footer>

</body>
</html>
