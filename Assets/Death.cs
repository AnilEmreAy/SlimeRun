using System.Collections;
using UnityEngine;

public class DeathZoneRespawn : MonoBehaviour
{
    public Transform respawnPoint;
    public float lockTime = 0.2f; // ayný ölüm alaný üst üste tetiklemesin

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

        // Hýzlarý sýfýrla (düþme/zýplama taþýnmasýn)
        var pm = other.GetComponent<PlayerMovement>();
        if (pm != null) pm.RespawnReset();

        // CC kapat -> güvenli teleport
        cc.enabled = false;

        other.transform.position = respawnPoint.position;
        other.transform.rotation = respawnPoint.rotation;

        // Transform deðiþimini fiziðe bildir
        Physics.SyncTransforms();

        // 1 frame bekle (çok kritik)
        yield return null;

        cc.enabled = true;

        // Çok kýsa kilit (ayný trigger içinde tekrar ölmesin)
        yield return new WaitForSeconds(lockTime);
        busy = false;
    }
}
