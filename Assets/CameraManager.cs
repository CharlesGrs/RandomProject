using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class CameraManager : MonoBehaviour
{
    [SerializeField] private float speed;
    [SerializeField] private float scrollSpeed;
    [SerializeField] private float damping;

    private Vector3 _velocity;
    private float zTarget;

    private void Start()
    {
        zTarget = transform.position.z;
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.D))
            _velocity.x += speed * Time.deltaTime;
        else if (Input.GetKey(KeyCode.Q))
            _velocity.x -= speed * Time.deltaTime;
        
        if (Input.GetKey(KeyCode.Z))
            _velocity.y += speed * Time.deltaTime;
        else if (Input.GetKey(KeyCode.S))
            _velocity.y -= speed * Time.deltaTime;

        if(Input.GetAxis("Mouse ScrollWheel") >0)
            zTarget += speed * Time.deltaTime * scrollSpeed;
        else if(Input.GetAxis("Mouse ScrollWheel") <0)
            zTarget -= speed * Time.deltaTime * scrollSpeed;

        var position = transform.position;
        var z = Mathf.Lerp(position.z, zTarget, speed * Time.deltaTime);
        position += new Vector3(_velocity.x, _velocity.y, 0);
        position = new Vector3(position.x, position.y, z);
        transform.position = position;

        if (transform.position.y < 1)
            transform.position = new Vector3(transform.position.x, 1, transform.position.z);

        if (_velocity.magnitude > 0)
            _velocity = Vector2.Lerp(_velocity, Vector2.zero, Time.deltaTime * damping );
    }
}