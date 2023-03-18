using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "PlaneData", menuName = "ScriptableObjects/Ground", order = 1)]
public class PlaneDataScriptable : ScriptableObject
{
    public Material PlaneMat;
    
    public int TesselationFactorX = 1;
    public int TesselationFactorY = 1;
    public int width = 10;
    public int length = 10;

    public void Copy(PlaneDataScriptable pd)
    {
        TesselationFactorX = pd.TesselationFactorX;
        TesselationFactorY = pd.TesselationFactorY;
        width = pd.width;
        length = pd.length;
        PlaneMat = pd.PlaneMat;
    }

    public bool Compare(PlaneDataScriptable pd)
    {
        return TesselationFactorX == pd.TesselationFactorX
               && TesselationFactorY == pd.TesselationFactorY
               && width == pd.width
               && length == pd.length
               && PlaneMat == pd.PlaneMat;
    }
}
