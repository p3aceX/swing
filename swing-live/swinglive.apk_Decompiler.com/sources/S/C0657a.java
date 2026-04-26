package s;

import android.graphics.Color;

/* JADX INFO: renamed from: s.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0657a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final float f6433a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final float f6434b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final float f6435c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final float f6436d;
    public final float e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final float f6437f;

    public C0657a(float f4, float f5, float f6, float f7, float f8, float f9) {
        this.f6433a = f4;
        this.f6434b = f5;
        this.f6435c = f6;
        this.f6436d = f7;
        this.e = f8;
        this.f6437f = f9;
    }

    public static C0657a a(int i4) {
        m mVar = m.f6461k;
        float fC = AbstractC0658b.c(Color.red(i4));
        float fC2 = AbstractC0658b.c(Color.green(i4));
        float fC3 = AbstractC0658b.c(Color.blue(i4));
        float[][] fArr = AbstractC0658b.f6441d;
        float[] fArr2 = fArr[0];
        float f4 = (fArr2[2] * fC3) + (fArr2[1] * fC2) + (fArr2[0] * fC);
        float[] fArr3 = fArr[1];
        float f5 = (fArr3[2] * fC3) + (fArr3[1] * fC2) + (fArr3[0] * fC);
        float[] fArr4 = fArr[2];
        float f6 = (fC3 * fArr4[2]) + (fC2 * fArr4[1]) + (fC * fArr4[0]);
        float[][] fArr5 = AbstractC0658b.f6438a;
        float[] fArr6 = fArr5[0];
        float f7 = (fArr6[2] * f6) + (fArr6[1] * f5) + (fArr6[0] * f4);
        float[] fArr7 = fArr5[1];
        float f8 = (fArr7[2] * f6) + (fArr7[1] * f5) + (fArr7[0] * f4);
        float[] fArr8 = fArr5[2];
        float f9 = (f6 * fArr8[2]) + (f5 * fArr8[1]) + (f4 * fArr8[0]);
        float[] fArr9 = mVar.f6467g;
        float f10 = fArr9[0] * f7;
        float f11 = fArr9[1] * f8;
        float f12 = fArr9[2] * f9;
        float fAbs = Math.abs(f10);
        float f13 = mVar.f6468h;
        float fPow = (float) Math.pow(((double) (fAbs * f13)) / 100.0d, 0.42d);
        float fPow2 = (float) Math.pow(((double) (Math.abs(f11) * f13)) / 100.0d, 0.42d);
        float fPow3 = (float) Math.pow(((double) (Math.abs(f12) * f13)) / 100.0d, 0.42d);
        float fSignum = ((Math.signum(f10) * 400.0f) * fPow) / (fPow + 27.13f);
        float fSignum2 = ((Math.signum(f11) * 400.0f) * fPow2) / (fPow2 + 27.13f);
        float fSignum3 = ((Math.signum(f12) * 400.0f) * fPow3) / (fPow3 + 27.13f);
        double d5 = fSignum3;
        float f14 = ((float) (((((double) fSignum2) * (-12.0d)) + (((double) fSignum) * 11.0d)) + d5)) / 11.0f;
        float f15 = ((float) (((double) (fSignum + fSignum2)) - (d5 * 2.0d))) / 9.0f;
        float f16 = fSignum2 * 20.0f;
        float f17 = ((21.0f * fSignum3) + ((fSignum * 20.0f) + f16)) / 20.0f;
        float f18 = (((fSignum * 40.0f) + f16) + fSignum3) / 20.0f;
        float fAtan2 = (((float) Math.atan2(f15, f14)) * 180.0f) / 3.1415927f;
        if (fAtan2 < 0.0f) {
            fAtan2 += 360.0f;
        } else if (fAtan2 >= 360.0f) {
            fAtan2 -= 360.0f;
        }
        float f19 = fAtan2;
        float f20 = (3.1415927f * f19) / 180.0f;
        float f21 = f18 * mVar.f6463b;
        float f22 = mVar.f6462a;
        float f23 = mVar.f6465d;
        float fPow4 = ((float) Math.pow(f21 / f22, mVar.f6470j * f23)) * 100.0f;
        Math.sqrt(fPow4 / 100.0f);
        float f24 = f22 + 4.0f;
        float fPow5 = ((float) Math.pow(1.64d - Math.pow(0.29d, mVar.f6466f), 0.73d)) * ((float) Math.pow((((((((float) (Math.cos(((((double) (((double) f19) < 20.14d ? f19 + 360.0f : f19)) * 3.141592653589793d) / 180.0d) + 2.0d) + 3.8d)) * 0.25f) * 3846.1538f) * mVar.e) * mVar.f6464c) * ((float) Math.sqrt((f15 * f15) + (f14 * f14)))) / (f17 + 0.305f), 0.9d)) * ((float) Math.sqrt(((double) fPow4) / 100.0d));
        float f25 = mVar.f6469i * fPow5;
        Math.sqrt((r3 * f23) / f24);
        float f26 = (1.7f * fPow4) / ((0.007f * fPow4) + 1.0f);
        float fLog = ((float) Math.log((f25 * 0.0228f) + 1.0f)) * 43.85965f;
        double d6 = f20;
        return new C0657a(f19, fPow5, fPow4, f26, fLog * ((float) Math.cos(d6)), fLog * ((float) Math.sin(d6)));
    }

    public static C0657a b(float f4, float f5, float f6) {
        m mVar = m.f6461k;
        float f7 = mVar.f6465d;
        Math.sqrt(((double) f4) / 100.0d);
        float f8 = mVar.f6462a + 4.0f;
        float f9 = mVar.f6469i * f5;
        Math.sqrt(((f5 / ((float) Math.sqrt(r1))) * mVar.f6465d) / f8);
        float f10 = (1.7f * f4) / ((0.007f * f4) + 1.0f);
        float fLog = ((float) Math.log((((double) f9) * 0.0228d) + 1.0d)) * 43.85965f;
        double d5 = (3.1415927f * f6) / 180.0f;
        return new C0657a(f6, f5, f4, f10, fLog * ((float) Math.cos(d5)), fLog * ((float) Math.sin(d5)));
    }

    /* JADX WARN: Removed duplicated region for block: B:8:0x001f  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final int c(s.m r21) {
        /*
            Method dump skipped, instruction units count: 380
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: s.C0657a.c(s.m):int");
    }
}
