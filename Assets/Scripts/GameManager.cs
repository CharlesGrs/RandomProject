using System;
using UnityEngine;
using UnityEngine.Events;

[System.Serializable]
public class StateEvent : UnityEvent<GameState>
{
}

public enum GameState
{
    Fight,
    Peaceful
}

public class GameManager : MonoBehaviour
{
    public GameObject entity;
    public static GameManager instance;
    private GameState _gameState;
    private EntityManager _entityManager;
    public StateEvent gameStateChange;

    private void Awake()
    {
        if (instance != null)
        {
            Debug.Log("An instance of GameManager already exists.");
            Destroy(this.gameObject);
            return;
        }
        instance = this;
    }
    
    private void Start()
    {
        _entityManager = new EntityManager
        {
            _gameManager = this
        };

        SetGameState(GameState.Peaceful);
    }


    private void SetGameState(GameState state)
    {
        _gameState = state;
        gameStateChange.Invoke(state);
    }
}