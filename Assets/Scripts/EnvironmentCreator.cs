using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Serialization;
using System.IO;

public class EnvironmentCreator : MonoBehaviour
{
    public TextAsset atlasDataFile;
    public Texture2D AtlasTexture;
    
    public Material environmentMaterial;
    public Material groundMaterial;
    
    //Starting to get tired
    private int _plantsAmount;

    public float humidityNoiseFrequency;
    public float humidityNoiseOffset;
    public float heightNoiseFrequency;
    public float heightNoiseStrength;
    public float heightNoiseOffset;
    
    [Range(0, MaxInstanceCount)] public int instanceCount = MaxInstanceCount;
    
    private const int MaxInstanceCount = 10000000;

    private ComputeBuffer _atlasDataBuffer;
    

    private 
    void Start()
    {
        TransferDatasFromSpriteAtlas();
        UpdateShaderProperties();
    }

    void Update()
    {
        UpdateShaderProperties();
        Graphics.DrawProcedural(
            environmentMaterial,
            new Bounds(transform.position, Vector3.one * instanceCount),
            MeshTopology.Triangles, instanceCount * 6, 1,
            null, null,
            ShadowCastingMode.Off, false, 6
        );
    }

    //Get Data from all sprites in a ComputeBuffer to be used to draw different sprites procedurally
    //Utils used with the dataBuffer to get "real variable strides" and differentiate textures
    //
    //Then send the ComputeBuffers on the GPU for later use
    void TransferDatasFromSpriteAtlas()
    {
        string[] lines = atlasDataFile.text.Split('\n');
        
        int count = lines.Length;
        _plantsAmount = count;
        int[] data = new int[count * 4];

        for (int i = 0; i < count; i++) {
            string[] values = lines[i].Split(',');
            data[i * 4] = int.Parse(values[1]);
            data[i * 4 + 1] = int.Parse(values[2]);
            data[i * 4 + 2] = int.Parse(values[3]);
            data[i * 4 + 3] = int.Parse(values[4]);
        }
        
        _atlasDataBuffer = new ComputeBuffer(count, sizeof(int) * 4,ComputeBufferType.Structured);
        _atlasDataBuffer.SetData(data);
        
        environmentMaterial.SetBuffer("_AtlasDataBuffer",_atlasDataBuffer);
    }

    void UpdateShaderProperties()
    {
        environmentMaterial.SetBuffer("_AtlasDataBuffer",_atlasDataBuffer);
        environmentMaterial.SetTexture("_AtlasTexture",AtlasTexture);
        environmentMaterial.SetInt("_atlasWidth",AtlasTexture.width);
        environmentMaterial.SetInt("_atlasHeight",AtlasTexture.height);
        environmentMaterial.SetInt("_plantsAmount",_plantsAmount);
        environmentMaterial.SetFloat("_humidityNoiseFrequency",humidityNoiseFrequency);
        environmentMaterial.SetFloat("_humidityNoiseOffset",humidityNoiseOffset);
        
        environmentMaterial.SetFloat("_heightNoiseFrequency",heightNoiseFrequency);
        environmentMaterial.SetFloat("_heightNoiseStrength",heightNoiseStrength);
        environmentMaterial.SetFloat("_heightNoiseOffset",heightNoiseOffset);
        
        groundMaterial.SetFloat("_humidityNoiseOffset",humidityNoiseOffset);
        groundMaterial.SetFloat("_humidityNoiseFrequency",humidityNoiseFrequency);
        groundMaterial.SetFloat("_heightNoiseFrequency",heightNoiseFrequency);
        groundMaterial.SetFloat("_heightNoiseStrength",heightNoiseStrength);
        groundMaterial.SetFloat("_heightNoiseOffset",heightNoiseOffset);
    }

    private void OnDestroy()
    {
        _atlasDataBuffer.Dispose();
    }
}
