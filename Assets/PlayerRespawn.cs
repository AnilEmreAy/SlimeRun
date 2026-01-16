using System.Collections;
using UnityEngine;

public class PlayerRespawn : MonoBehaviour
{
    public Transform respawnPoint;
    public float respawnLockTime = 0.3f;

    private bool isRespawning = false;
    public bool IsRespawning => isRespawning;

    public void KillAndRespawn()
    {
        if (isRespawning) return;
        StartCoroutine(RespawnRoutine());
    }

    IEnumerator RespawnRoutine()
    {
        isRespawning = true;

        
        var pm = GetComponent<PlayerMovement>();
        if (pm != null) pm.RespawnReset();

        
        var cc = GetComponent<CharacterController>();
        if (cc != null) cc.enabled = false;

        
        if (respawnPoint != null)
        {
            transform.position = respawnPoint.position;
            transform.rotation = respawnPoint.rotation;
        }

        
        Physics.SyncTransforms();

        
        yield return null;

        if (cc != null) cc.enabled = true;

        
        yield return new WaitForSeconds(respawnLockTime);

        isRespawning = false;
    }
}
