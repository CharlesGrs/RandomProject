using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "GameData", fileName = "InputData")]
public class InputData : ScriptableObject
{
    public KeyCode Forward;
    public KeyCode Backward;
    public KeyCode Right;
    public KeyCode Left;
}
