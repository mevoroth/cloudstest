using UnityEngine;
using System.Collections;

public class Raymarching : MonoBehaviour {
	public Material Material;
	public NoiseGenerator NoiseGen;
	// Use this for initialization
	void Start ()
	{
	}

	void Update()
	{
		Material.SetTexture ("_DepthTex", transform.parent.GetComponent<Depth> ()._renderTexture);
		for (int i = 0; i < 8; ++i)
		{
			Material.SetTexture("_Noise" + i, NoiseGen.NoiseTextures[i]);
		}
	}

	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit (source, destination, Material);
	}
}
