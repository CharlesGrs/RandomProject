using System.Collections.Generic;
using UnityEngine;

public class EntityManager
{
    public GameManager _gameManager;
    private GameState _gameState;
    public List<Entity> nonPlayerEntities;
    public List<Entity> playerEntities;

    public EntityManager()
    {
        CreatePlayer();
    }

    public void CreatePlayer()
    {
        var entity = new Entity();
        playerEntities.Add(entity);
    }


    
}
