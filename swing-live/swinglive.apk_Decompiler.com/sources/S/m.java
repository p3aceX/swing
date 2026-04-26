package s;

/* JADX INFO: loaded from: classes.dex */
public final class m {

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public static final m f6461k;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final float f6462a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final float f6463b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final float f6464c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final float f6465d;
    public final float e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final float f6466f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final float[] f6467g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final float f6468h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final float f6469i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final float f6470j;

    static {
        float[] fArr = AbstractC0658b.f6440c;
        float fG = (float) ((((double) AbstractC0658b.g()) * 63.66197723675813d) / 100.0d);
        float[][] fArr2 = AbstractC0658b.f6438a;
        float f4 = fArr[0];
        float[] fArr3 = fArr2[0];
        float f5 = fArr3[0] * f4;
        float f6 = fArr[1];
        float f7 = (fArr3[1] * f6) + f5;
        float f8 = fArr[2];
        float f9 = (fArr3[2] * f8) + f7;
        float[] fArr4 = fArr2[1];
        float f10 = (fArr4[2] * f8) + (fArr4[1] * f6) + (fArr4[0] * f4);
        float[] fArr5 = fArr2[2];
        float f11 = (f8 * fArr5[2]) + (f6 * fArr5[1]) + (f4 * fArr5[0]);
        float f12 = ((double) 1.0f) >= 0.9d ? 0.69f : 0.655f;
        float fExp = (1.0f - (((float) Math.exp(((-fG) - 42.0f) / 92.0f)) * 0.2777778f)) * 1.0f;
        double d5 = fExp;
        if (d5 > 1.0d) {
            fExp = 1.0f;
        } else if (d5 < 0.0d) {
            fExp = 0.0f;
        }
        float[] fArr6 = {(((100.0f / f9) * fExp) + 1.0f) - fExp, (((100.0f / f10) * fExp) + 1.0f) - fExp, (((100.0f / f11) * fExp) + 1.0f) - fExp};
        float f13 = 1.0f / ((5.0f * fG) + 1.0f);
        float f14 = f13 * f13 * f13 * f13;
        float f15 = 1.0f - f14;
        float fCbrt = (0.1f * f15 * f15 * ((float) Math.cbrt(((double) fG) * 5.0d))) + (f14 * fG);
        float fG2 = AbstractC0658b.g() / fArr[1];
        double d6 = fG2;
        float fSqrt = ((float) Math.sqrt(d6)) + 1.48f;
        float fPow = 0.725f / ((float) Math.pow(d6, 0.2d));
        float[] fArr7 = {(float) Math.pow(((double) ((fArr6[0] * fCbrt) * f9)) / 100.0d, 0.42d), (float) Math.pow(((double) ((fArr6[1] * fCbrt) * f10)) / 100.0d, 0.42d), (float) Math.pow(((double) ((fArr6[2] * fCbrt) * f11)) / 100.0d, 0.42d)};
        float f16 = fArr7[0];
        float f17 = (f16 * 400.0f) / (f16 + 27.13f);
        float f18 = fArr7[1];
        float f19 = (f18 * 400.0f) / (f18 + 27.13f);
        float f20 = fArr7[2];
        float[] fArr8 = {f17, f19, (400.0f * f20) / (f20 + 27.13f)};
        f6461k = new m(fG2, ((fArr8[2] * 0.05f) + (fArr8[0] * 2.0f) + fArr8[1]) * fPow, fPow, fPow, f12, 1.0f, fArr6, fCbrt, (float) Math.pow(fCbrt, 0.25d), fSqrt);
    }

    public m(float f4, float f5, float f6, float f7, float f8, float f9, float[] fArr, float f10, float f11, float f12) {
        this.f6466f = f4;
        this.f6462a = f5;
        this.f6463b = f6;
        this.f6464c = f7;
        this.f6465d = f8;
        this.e = f9;
        this.f6467g = fArr;
        this.f6468h = f10;
        this.f6469i = f11;
        this.f6470j = f12;
    }
}
