using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : Entity
{
    public InputData input;

    public float speed;
    private static readonly int PlayerPosWs = Shader.PropertyToID("_PlayerPosWS");

    public override void Start()
    {
        base.Start();
    }

    public void Update()
    {
        var velocity = Vector2.zero;

        if (Input.GetKey(input.Forward))
        {
            velocity += Vector2.up;
        }
        else if (Input.GetKey(input.Backward))
        {
            velocity += Vector2.down;
        }

        if (Input.GetKey(input.Right))
        {
            velocity += Vector2.right;
        }
        else if (Input.GetKey(input.Left))
        {
            velocity += Vector2.left;
        }

        velocity *= speed * Time.deltaTime;

        transform.position += new Vector3(velocity.x, 0, velocity.y);
        Shader.SetGlobalVector(PlayerPosWs, transform.position);
    }
}