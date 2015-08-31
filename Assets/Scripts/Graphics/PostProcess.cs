using UnityEngine;
using System.Collections;

public class PostProcess : MonoBehaviour
{
	public Material PostProcessMaterial;

	void Update()
	{
		Camera cam = GetComponent<Camera>();
		PostProcessMaterial.SetMatrix("MVPInverseMatrix", (cam.projectionMatrix * cam.worldToCameraMatrix).inverse);
		Debug.Log((cam.projectionMatrix * cam.worldToCameraMatrix).inverse);
	}

	void OnRenderImage(RenderTexture Source, RenderTexture Destination)
	{
		Graphics.Blit(Source, Destination, PostProcessMaterial);
	}
}
