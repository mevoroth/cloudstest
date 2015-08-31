using UnityEngine;
using System.Collections;

public class Depth : MonoBehaviour
{
	Camera _cam;
	public Shader Shader;
	public RenderTexture _renderTexture;
	public Material Material;

	// Use this for initialization
	void Start () {
		_cam = GetComponent<Camera> ();
		_cam.depthTextureMode = DepthTextureMode.Depth;
		_renderTexture = new RenderTexture (Screen.width, Screen.height, 0, RenderTextureFormat.RFloat, RenderTextureReadWrite.Default);
		_renderTexture.filterMode = FilterMode.Point;
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit (source, _renderTexture, Material);
	}
}
