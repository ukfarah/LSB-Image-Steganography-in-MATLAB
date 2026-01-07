

# 🕵️‍♂️ **LSB IMAGE STEGANOGRAPHY SYSTEM**

## **Secure Message Hiding in Images using MATLAB**

---

## 🧠 **OVERVIEW**

This project implements a **Least Significant Bit (LSB) Image Steganography System** using MATLAB.
It allows users to:

✅ Hide secret messages inside images
✅ Extract hidden messages from stego-images
✅ Preserve the visual quality of the image
✅ Provide an efficient and simple steganography workflow

The system modifies only the **least significant bits of pixel values**, ensuring that the embedded data remains visually undetectable.

---

## 🎯 **OBJECTIVE**

* Hide sensitive text information inside images securely
* Reduce risk of direct message interception
* Support safe communication through multimedia files
* Demonstrate practical steganography principles in MATLAB

---

## ⚙️ **WORKFLOW**

* Load a cover image
* Convert secret message into binary
* Embed message bits into the **LSB of image pixels**
* Save the resulting stego-image
* Load stego-image for decoding
* Extract bits from LSB
* Reconstruct original text message

---

## 🏗️ **PROJECT STRUCTURE**

✅ `runProject.m`

* Main runner script for executing the full system

✅ `LSB_Steganography.m`

* Core algorithm implementation for embedding + extracting

✅ `core.m`

* Helper functions for handling image processing and conversions

✅ `config.m`

* Configuration file for setting paths, parameters, and constants

---

## 🧠 **ALGORITHM**

### **Encoding (Embedding)**

1. Convert message into binary stream
2. Insert each bit into the LSB of pixel values
3. Store the message length or termination marker
4. Output stego-image

### **Decoding (Extraction)**

1. Read LSB values from stego-image pixels
2. Reconstruct binary stream
3. Convert back to readable text
4. Output decoded message

---

## ✨ **FEATURES**

* ✅ Text-to-image embedding
* ✅ Image-to-text decoding
* ✅ High invisibility (minimal distortion)
* ✅ MATLAB-based implementation
* ✅ Modular structure for easy extension
* ✅ Configurable parameters using `config.m`

---

## 🧩 **REQUIREMENTS**

### **Prerequisites**

* MATLAB R2018+ (or any version supporting basic image I/O)

### **MATLAB Functions Used**

* `imread()`
* `imwrite()`
* `bitset()`
* `bitget()`
* `uint8()`

---

## ▶️ **RUN**

### ✅ Step 1: Open MATLAB

Place all files in the same folder.

### ✅ Step 2: Run the project

```matlab
runProject
```

---

## 🧪 **USAGE**

### **Encoding**

* Choose input cover image
* Enter secret message
* Generate stego-image

### **Decoding**

* Select stego-image
* Extract hidden message
* Display output

---

## 💡 **EXAMPLE INPUTS**

* Message: `"Hello World"`
* Image: `cover.png`

✅ Output: `stego.png` (looks visually identical)

---

## 📤 **OUTPUT**

* **Stego Image File**
* **Decoded Secret Message**
* Optional:

  * Message length
  * Encoding success indicator

---

## 🧠 **DESIGN DECISIONS**

* LSB chosen for simplicity and low visual distortion
* Modular function separation for maintainability
* Configurable settings through `config.m`
* Supports grayscale or RGB depending on implementation

---

## ⚠️ **LIMITATIONS**

* LSB steganography is not resistant to heavy compression
* Limited capacity depending on image size
* Detection possible under advanced steganalysis tools
* Message extraction requires correct decoding format

---

## 📚 **REFERENCES**

* Johnson & Jajodia, *Steganalysis and Countermeasures*, 1998
* LSB Steganography Research Papers
* MATLAB Image Processing Documentation


