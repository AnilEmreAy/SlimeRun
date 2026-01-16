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

        // Hareket scripti varsa hýzlarý sýfýrla
        var pm = GetComponent<PlayerMovement>();
        if (pm != null) pm.RespawnReset();

        // CC varsa güvenli teleport için kýsa süre kapat
        var cc = GetComponent<CharacterController>();
        if (cc != null) cc.enabled = false;

        // Respawn noktasýna koy
        if (respawnPoint != null)
        {
            transform.position = respawnPoint.position;
            transform.rotation = respawnPoint.rotation;
        }

        // Unity transform'u senkronlasýn
        Physics.SyncTransforms();

        // 1 frame bekle (çok önemli)
        yield return null;

        if (cc != null) cc.enabled = true;

        // Çok kýsa süre tekrar öldürmeyi kilitle (spam engeli)
        yield return new WaitForSeconds(respawnLockTime);

        isRespawning = false;
    }
}
