using UnityEditor;
using UnityEngine;

public class Entity : MonoBehaviour
{
    private GameState _gameState;

    public virtual void Start()
    {
        if (GameManager.instance == null)
        {
            Debug.Log("No GameManager instance exists");
            return;
        }

        GameManager.instance.gameStateChange.AddListener(ChangeGameState);
    }


    void ChangeGameState(GameState state)
    {
        _gameState = state;
    }

   
  
}