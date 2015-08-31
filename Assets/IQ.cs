using UnityEngine;
using System.Collections;

public class IQ : MonoBehaviour {
    public Material Material;
    public RenderTexture Clouds;
	// Use this for initialization
	void Start () {
        Clouds = new RenderTexture(1980, 1080, 24);
        //GetComponent<Camera>().targetTexture = Clouds;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, Material);
    }
}
