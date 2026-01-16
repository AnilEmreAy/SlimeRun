using System.Collections;
using UnityEngine;

public class TimedGateSlide : MonoBehaviour
{
    [Header("Doors")]
    public Transform door1;
    public Transform door2;

    [Header("Open Offsets (how far doors move when opening)")]
    public Vector3 door1OpenOffset = new Vector3(-2f, 0f, 0f);
    public Vector3 door2OpenOffset = new Vector3(2f, 0f, 0f);

    [Header("Timing")]
    public float openDuration = 5f; // kaç saniye açýk kalsýn

    private Vector3 door1ClosedPos;
    private Vector3 door2ClosedPos;

    private bool isOpen = false;
    private Coroutine timerRoutine;

    void Start()
    {
        if (door1 != null) door1ClosedPos = door1.position;
        if (door2 != null) door2ClosedPos = door2.position;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        Open();

        // Butona tekrar basýlýrsa süreyi yeniden baþlat
        if (timerRoutine != null) StopCoroutine(timerRoutine);
        timerRoutine = StartCoroutine(CloseAfterDelay());
    }

    void Open()
    {
        if (isOpen) return;

        if (door1 != null) door1.position = door1ClosedPos + door1OpenOffset;
        if (door2 != null) door2.position = door2ClosedPos + door2OpenOffset;

        isOpen = true;
    }

    IEnumerator CloseAfterDelay()
    {
        yield return new WaitForSeconds(openDuration);
        Close();
        timerRoutine = null;
    }

    void Close()
    {
        if (!isOpen) return;

        if (door1 != null) door1.position = door1ClosedPos;
        if (door2 != null) door2.position = door2ClosedPos;

        isOpen = false;
    }
}
