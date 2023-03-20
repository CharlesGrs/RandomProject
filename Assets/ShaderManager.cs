using UnityEngine;
[ExecuteAlways]
public class ShaderManager : MonoBehaviour
{
    private const string BendingFeature = "ENABLE_BENDING";
    void Update()
    {
        if(Application.IsPlaying(gameObject))
        {
            Shader.EnableKeyword(BendingFeature);
        }
        else
        {
            Shader.DisableKeyword(BendingFeature);
        }
    }
}
