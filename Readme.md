-------------------------------------------

   TecnoBoda

-------------------------------------------
Este proyecto depende del SDK de Catchoom.
El SDK trae 3 archivos
 - CraftARAugmentedRealitySDK.framework
 - CraftARResourcesAR.bundle
 - Pods.framework

Estos archivos se deben colocar un nivel superior
a la carpeta del projecto.

Por ejemplo: si creamos una carpeta llamada
Proyecto y dentro de este creamos una subcarpeta
Src, los archivos de dependencia deben estar en
Proyecto y el codigo del repositorio en Src.

Quedando de la siguiente manera.

~/Proyecto/CraftARAugmentedRealitySDK.framework
~/Proyecto/CraftARResourcesAR.bundle
~/Proyecto/Pods.framework
~/Proyecto/Src/itarbasesac-boda.xcodeproj
~/Proyecto/Src/itarbasesac-boda/*