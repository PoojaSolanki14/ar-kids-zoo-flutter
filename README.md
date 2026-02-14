# 🦁 AR Kids Zoo – Flutter Augmented Reality App

AR Kids Zoo is a Flutter-based Augmented Reality (AR) application designed for children to explore animals in an interactive and engaging way using real-world AR placement on supported Android devices.

---

## 🎥 Demo Video (Screen Recording)

Watch the complete working demo of the AR Kids Zoo application here:

🔗 **Google Drive Video:**
[https://drive.google.com/file/d/1Y_dB0KmeWIcOzWv2ecK1fs9K81rq2446/view?usp=sharing](https://drive.google.com/file/d/1Y_dB0KmeWIcOzWv2ecK1fs9K81rq2446/view?usp=sharing)

The demo video shows:

* App launch
* AR plane detection
* 3D animal placement
* Object interaction (scale and rotate)
* Real device AR testing

---

## 📱 Features

* 🦁 Augmented Reality animal placement
* 🖐 Tap to place 3D animal models on detected surfaces
* 🔄 Scale and rotate 3D objects
* 📸 Real-time camera-based AR experience
* 🎨 Kid-friendly and simple user interface
* ⚡ Smooth performance on ARCore-supported devices

---

## 🛠️ Tech Stack

* **Flutter** (Dart)
* **ARCore**
* **ar_flutter_plugin**
* **Android**

---

## 📦 AR Plugin Used

**Plugin Name:** `ar_flutter_plugin`

### Why this plugin?

* Supports ARCore for Android
* Easy plane detection
* Simple 3D model placement (GLB / GLTF)
* Suitable for educational AR applications

---

## 📂 Project Structure

```
ar_kids_zoo/
│── lib/
│   ├── main.dart
│   ├── screens/
│   ├── widgets/
│── android/
│── assets/
│   ├── models/
│── pubspec.yaml
│── README.md
```

---

## 📱 Device & Testing Details

* **Tested on:** Real Android device
* **Android Version:** Android 10+
* **AR Support:** ARCore-supported device required

⚠️ AR features will not work on emulators.

---

## ▶️ How to Run the Project

1. Clone the repository:

   ```bash
   git clone https://github.com/PoojaSolanki14/ar-kids-zoo-flutter.git
   ```

2. Navigate to the project directory:

   ```bash
   cd ar-kids-zoo-flutter
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application on a real Android device:

   ```bash
   flutter run
   ```

---

## 📦 APK Build Instructions

To generate the release APK:

```bash
flutter build apk --release
```

APK file location:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🚀 Future Improvements

* Add animal sound effects
* Display educational information for each animal
* Support multiple animals simultaneously
* Add animations to 3D models
* iOS ARKit support

---

## 🤖 AI Usage Disclosure

AI tools were used for:

* Understanding AR concepts
* Improving code structure
* Documentation assistance

All implementation, testing, and final integration were done manually.

---

## 👩‍💻 Developed By

**Pooja Solanki**
Flutter Developer

GitHub: [https://github.com/PoojaSolanki14](https://github.com/PoojaSolanki14)

---

## 📄 License

This project is developed for educational and assessment purposes.

---
