using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundManager : MonoBehaviour
{

    public PlaneDataScriptable PlaneData;

    private MeshRenderer _meshRenderer;
    private MeshFilter _meshFilter;
    
    private PlaneDataScriptable currentPlaneData;
    private Vector3 _middleGroundPos;
    private List<GameObject> _grounds;
    
    void Start()
    {
        transform.position = Vector3.zero;
        _meshFilter = GetComponent<MeshFilter>();
        _meshRenderer = GetComponent<MeshRenderer>();
        
        currentPlaneData = ScriptableObject.CreateInstance<PlaneDataScriptable>();
        currentPlaneData.Copy(PlaneData);
        CreateMesh();
    }
    void Update()
    {
        if (!currentPlaneData.Compare(PlaneData))
        {
            CreateMesh();
            currentPlaneData.Copy(PlaneData);
        }
    }
    private void CreateMesh()
    {
        if (PlaneData.TesselationFactorX <= 0 || PlaneData.TesselationFactorY <= 0)
            return;
        
        Mesh mesh = new Mesh();

        int numVertices = (PlaneData.TesselationFactorX + 1) * (PlaneData.TesselationFactorY + 1);
        Vector3[] vertices = new Vector3[numVertices];
        Vector2[] uv = new Vector2[numVertices];

        int index = 0;
        for (int z = 0; z <= PlaneData.TesselationFactorY; z++)
        {
            for (int x = 0; x <= PlaneData.TesselationFactorX; x++)
            {
                float u = (float)x / PlaneData.TesselationFactorX;
                float v = (float)z / PlaneData.TesselationFactorY;

                vertices[index] = new Vector3((u - 0.5f) * PlaneData.width, 0, (v - 0.5f) * PlaneData.length);
                uv[index] = new Vector2(u, v);

                index++;
            }
        }

        int[] triangles = new int[PlaneData.TesselationFactorX * PlaneData.TesselationFactorY * 6];

        index = 0;
        for (int z = 0; z < PlaneData.TesselationFactorY; z++)
        {
            for (int x = 0; x < PlaneData.TesselationFactorX; x++)
            {
                int a = x + (PlaneData.TesselationFactorX + 1) * z;
                int b = a + 1;
                int c = a + (PlaneData.TesselationFactorX + 1);
                int d = c + 1;

                triangles[index] = a;
                triangles[index + 1] = c;
                triangles[index + 2] = b;
                triangles[index + 3] = b;
                triangles[index + 4] = c;
                triangles[index + 5] = d;

                index += 6;
            }
        }

        mesh.vertices = vertices;
        mesh.uv = uv;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        
        _meshFilter.mesh = mesh;
        _meshRenderer.material = PlaneData.PlaneMat;
    }

}
