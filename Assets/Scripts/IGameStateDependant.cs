
public abstract class GameStateDependant
{
    private GameState _gameState;
    public void ChangeGameState(GameState gameState)
    {
        _gameState = gameState;
    }
}