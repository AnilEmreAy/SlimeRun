using System.Collections;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class SpiderPlayerController : MonoBehaviour
{
    [Header("Movement")]
    public float walkSpeed = 5f;
    public float runSpeed = 8f;
    public float rotationSpeed = 10f;
    public float jumpHeight = 2f;
    public float gravity = -9.81f;

    [Header("Stretch/Scale")]
    public float stretchSpeed = 5f;
    public Vector3 normalScale = Vector3.one;
    public Vector3 tallScale = new Vector3(0.7f, 2f, 0.7f);
    public Vector3 shortScale = new Vector3(1.5f, 0.5f, 1.5f);

    [Header("Camera")]
    public Transform cam;

    [Header("Web Swing")]
    public GameObject webPrefab;
    public Transform handTransform;
    public float webSpeed = 50f;
    public float swingSpring = 50f;
    public float swingDamper = 5f;

    private CharacterController controller;
    private Vector3 velocity;
    private bool isGrounded;

    private GameObject currentWeb;
    private SpringJoint webJoint;
    private LineRenderer webLine;

    void Start()
    {
        controller = GetComponent<CharacterController>();
        if (cam == null && Camera.main != null)
            cam = Camera.main.transform;
    }

    void Update()
    {
        GroundCheck();
        if (webJoint == null)
        {
            Move();
            Jump();
        }
        ApplyGravity();
        StretchCharacter();
        HandleWeb();
        UpdateWebLine();
    }

    void GroundCheck()
    {
        isGrounded = controller.isGrounded;
        if (isGrounded && velocity.y < 0)
            velocity.y = -2f;
    }

    void Move()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");
        Vector3 move = new Vector3(horizontal, 0, vertical).normalized;

        if (move.magnitude >= 0.1f)
        {
            Vector3 camForward = cam.forward;
            camForward.y = 0;
            camForward.Normalize();

            Vector3 camRight = cam.right;
            camRight.y = 0;
            camRight.Normalize();

            Vector3 moveDir = (camForward * vertical + camRight * horizontal).normalized;

            Quaternion targetRotation = Quaternion.LookRotation(moveDir);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);

            float speed = Input.GetKey(KeyCode.LeftShift) ? runSpeed : walkSpeed;
            controller.Move(moveDir * speed * Time.deltaTime);
        }
    }

    void Jump()
    {
        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
        }
    }

    void ApplyGravity()
    {
        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
    }

    void StretchCharacter()
    {
        Vector3 targetScale = normalScale;
        if (Input.GetKey(KeyCode.Alpha1))
            targetScale = tallScale;
        else if (Input.GetKey(KeyCode.Alpha2))
            targetScale = shortScale;

        transform.localScale = Vector3.Lerp(transform.localScale, targetScale, Time.deltaTime * stretchSpeed);
    }

    void HandleWeb()
    {
        // Web f�rlatma
        if (Input.GetMouseButtonDown(0) && webPrefab != null && webJoint == null)
        {
            currentWeb = Instantiate(webPrefab, handTransform.position, Quaternion.identity);
            Rigidbody webRb = currentWeb.GetComponent<Rigidbody>();
            if (webRb != null)
                webRb.linearVelocity = cam.forward * webSpeed;

            // SpringJoint ile oyuncuyu �ek
            webJoint = gameObject.AddComponent<SpringJoint>();
            webJoint.autoConfigureConnectedAnchor = false;
            webJoint.connectedAnchor = handTransform.position + cam.forward * 10f; // Web hedef pozisyonu
            webJoint.spring = swingSpring;
            webJoint.damper = swingDamper;
            webJoint.maxDistance = 0f;

            // LineRenderer ekle
            webLine = currentWeb.AddComponent<LineRenderer>();
            webLine.startWidth = 0.05f;
            webLine.endWidth = 0.05f;
            webLine.positionCount = 2;
            webLine.material = new Material(Shader.Find("Sprites/Default"));
            webLine.startColor = Color.white;
            webLine.endColor = Color.white;
        }

        // Web b�rakma
        if (Input.GetMouseButtonUp(0) && webJoint != null)
        {
            Destroy(webJoint);
            webJoint = null;
            if (currentWeb != null)
                Destroy(currentWeb);
        }
    }

    void UpdateWebLine()
    {
        if (webLine != null)
        {
            webLine.SetPosition(0, handTransform.position);
            if (currentWeb != null)
                webLine.SetPosition(1, currentWeb.transform.position);
        }
    }
}
