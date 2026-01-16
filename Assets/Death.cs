using System.Collections;
using UnityEngine;

public class DeathZoneRespawn : MonoBehaviour
{
    public Transform respawnPoint;
    public float lockTime = 0.2f; 

    private bool busy = false;

    private void OnTriggerEnter(Collider other)
    {
        if (busy) return;
        if (!other.CompareTag("Player")) return;
        if (respawnPoint == null) return;

        StartCoroutine(RespawnRoutine(other));
    }

    private IEnumerator RespawnRoutine(Collider other)
    {
        busy = true;

        var cc = other.GetComponent<CharacterController>();
        if (cc == null) { busy = false; yield break; }

        
        var pm = other.GetComponent<PlayerMovement>();
        if (pm != null) pm.RespawnReset();

        
        cc.enabled = false;

        other.transform.position = respawnPoint.position;
        other.transform.rotation = respawnPoint.rotation;

       
        Physics.SyncTransforms();

       
        yield return null;

        cc.enabled = true;

        
        yield return new WaitForSeconds(lockTime);
        busy = false;
    }
}
