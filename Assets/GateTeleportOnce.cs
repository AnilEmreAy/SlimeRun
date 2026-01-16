using UnityEngine;

public class GateSlideOnce : MonoBehaviour
{
    public Transform door1;
    public Transform door2;

    public Vector3 door1OpenOffset = new Vector3(-2f, 0f, 0f);
    public Vector3 door2OpenOffset = new Vector3(2f, 0f, 0f);

    private bool opened = false;
    private AudioSource audioSource;

    void Start()
    {
        audioSource = GetComponent<AudioSource>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (opened) return;
        if (!other.CompareTag("Player")) return;

        if (door1 != null)
            door1.position += door1OpenOffset;

        if (door2 != null)
            door2.position += door2OpenOffset;

        
        if (audioSource != null)
            audioSource.Play();

        opened = true;
    }
}
