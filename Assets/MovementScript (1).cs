using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PlayerMovement : MonoBehaviour
{
    [Header("Movement")]
    public float walkSpeed = 5f;
    public float runSpeed = 8f;
    public float rotationSpeed = 10f;

    [Header("Jump")]
    public float jumpForce = 8f;
    public float gravity = -20f;
    public float jumpCooldown = 0.6f;

    [Header("Camera")]
    public Transform cam;

    [Header("Scale")]
    public float stretchSpeed = 8f;

    [Tooltip("Normal boyut (uniform)")]
    public float normalSize = 1.2f;

    [Tooltip("Küçülme: her yönde aynı küçülür (uniform)")]
    public float shortSize = 0.6f;

    [Tooltip("Uzama: çubuk gibi (Y büyür, X/Z incelir)")]
    public Vector3 tallScale = new Vector3(0.5f, 3.0f, 0.5f);

    // Internal
    private CharacterController controller;
    private Vector3 moveVelocity;     // yatay hız (world)
    private float verticalVelocity;   // dikey hız (jump/gravity)
    private float lastJumpTime = -999f;

    void Start()
    {
        controller = GetComponent<CharacterController>();

        if (cam == null && Camera.main != null)
            cam = Camera.main.transform;
    }

    void Update()
    {
        // Güvenlik: CC kapalıysa hiçbir şey yapma (hata basmasın)
        if (controller == null || !controller.enabled) return;

        HandleMovement();
        HandleJump();
        ApplyGravity();
        HandleScale();

        // TEK Move
        Vector3 finalMove = moveVelocity;
        finalMove.y = verticalVelocity;
        controller.Move(finalMove * Time.deltaTime);
    }

    void HandleMovement()
    {
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");

        Vector3 dir;

        if (cam != null)
        {
            Vector3 camForward = cam.forward;
            camForward.y = 0;
            camForward.Normalize();

            Vector3 camRight = cam.right;
            camRight.y = 0;
            camRight.Normalize();

            dir = (camForward * v + camRight * h).normalized;
        }
        else
        {
            dir = new Vector3(h, 0, v).normalized;
        }

        if (dir.sqrMagnitude > 0.01f)
        {
            Quaternion targetRot = Quaternion.LookRotation(dir);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRot, rotationSpeed * Time.deltaTime);
        }

        float speed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed;
        moveVelocity = dir * speed;
    }

    void HandleJump()
    {
        if (Input.GetKeyDown(KeyCode.Space) && Time.time >= lastJumpTime + jumpCooldown)
        {
            verticalVelocity = jumpForce;
            lastJumpTime = Time.time;
        }
    }

    void ApplyGravity()
    {
        verticalVelocity += gravity * Time.deltaTime;
    }

    void HandleScale()
    {
        Vector3 normalScale = Vector3.one * normalSize;
        Vector3 shortScale = Vector3.one * shortSize;

        Vector3 targetScale = normalScale;

        if (Input.GetKey(KeyCode.Alpha1))
        {
            targetScale = tallScale;      // çubuk gibi uzar
        }
        else if (Input.GetKey(KeyCode.Alpha2))
        {
            targetScale = shortScale;     // uniform küçülür
        }

        transform.localScale = Vector3.Lerp(transform.localScale, targetScale, Time.deltaTime * stretchSpeed);
    }

    // ✅ Respawn/ölüm sonrası "saçma fırlama" olmasın diye çağır
    public void RespawnReset()
    {
        verticalVelocity = 0f;
        moveVelocity = Vector3.zero;
        lastJumpTime = -999f;
    }
}
