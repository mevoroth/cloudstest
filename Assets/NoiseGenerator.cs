using UnityEngine;
using System.Collections;

public class NoiseGenerator : MonoBehaviour
{
	public float Width;
	public float Height;
	public float Scale;
	public Texture2D[] NoiseTextures;
	public Color[] Pixels;

	// Use this for initialization
	void Start ()
	{
		NoiseTextures = new Texture2D[8];
		for (int i = 0; i < 8; ++i)
		{
			float Seed = Random.Range(0f, 1f);
			Texture2D NoiseTexture = new Texture2D ((int)Width, (int)Height, TextureFormat.RGBA32, false);
			Pixels = new Color[(int)(Width * Height)];
			for (float y = 0; y < Height; ++y)
			{
				for (float x = 0; x < Width; ++x)
				{
					float Sample = Mathf.PerlinNoise(x * Scale / Width + Seed, y * Scale / Height + Seed);
					Pixels[(int)(y * Width + x)] = new Color(Sample, Sample, Sample);
				}
			}
			NoiseTexture.SetPixels (Pixels);
			NoiseTexture.Apply ();
			NoiseTextures[i] = NoiseTexture;

            if (i == 0)
            {
                byte[] pngbytes = NoiseTexture.EncodeToPNG();
                System.IO.File.WriteAllBytes(Application.dataPath + "\\noise.png", pngbytes);
            }
		}
	}
}
