# Demo Scenes
Demo scens can be found in：
- 📂 Symphonie/Models/Slime/Demo/
    - 📄Demo.unity
    - 📄 AnimDisplay.unity - **For showcasing animations**

# Shader
Shader for built-in pipeline and URP are provided. *No support for HDRP.*

> 💡The shader is construct using Amplfy Shader Editor.
>
> ❗Please note that the built-in pipeline version is missing a node I need, so I have to copy and modify the original "Indirect Specular Lighting" node. I can't share the source file because it's essentially a copy of ASE's source code. **THIS WILL NOT AFFECT THE SHADER FUNCTIONALITY**. It only matters if you want to modify the shader. And the URP version works fine.

# Scripts
This package includes several useful scripts:
- 📂 Symphonie/Models/Slime/Scripts/
    - 📄 SlimeVisual.cs - **For correctly render the model with provided shader**
    - 📂 Editor
        - 📄 CoreScatterLUTBakerWizard.cs - **A utility for baking the Lookup Table for the core scattering effect**
- 📂 Symphonie/Models/Slime/Demo/
    - 📄 SlimeController.cs - **For controlling the slime by AI or player**
