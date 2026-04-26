package io.flutter.view;

import I.C0053n;
import android.graphics.Rect;
import android.opengl.Matrix;
import android.text.SpannableString;
import android.text.TextUtils;
import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public String f4735A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public String f4736B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public int f4737C;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public long f4740F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public int f4741G;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public int f4742H;

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public int f4743I;
    public float J;

    /* JADX INFO: renamed from: K, reason: collision with root package name */
    public String f4744K;

    /* JADX INFO: renamed from: L, reason: collision with root package name */
    public String f4745L;

    /* JADX INFO: renamed from: M, reason: collision with root package name */
    public float f4746M;

    /* JADX INFO: renamed from: N, reason: collision with root package name */
    public float f4747N;

    /* JADX INFO: renamed from: O, reason: collision with root package name */
    public float f4748O;

    /* JADX INFO: renamed from: P, reason: collision with root package name */
    public float f4749P;

    /* JADX INFO: renamed from: Q, reason: collision with root package name */
    public float[] f4750Q;

    /* JADX INFO: renamed from: R, reason: collision with root package name */
    public float[] f4751R;

    /* JADX INFO: renamed from: S, reason: collision with root package name */
    public j f4752S;

    /* JADX INFO: renamed from: V, reason: collision with root package name */
    public ArrayList f4755V;

    /* JADX INFO: renamed from: W, reason: collision with root package name */
    public i f4756W;

    /* JADX INFO: renamed from: X, reason: collision with root package name */
    public i f4757X;

    /* JADX INFO: renamed from: Z, reason: collision with root package name */
    public float[] f4759Z;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final k f4760a;

    /* JADX INFO: renamed from: b0, reason: collision with root package name */
    public float[] f4763b0;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public long f4764c;

    /* JADX INFO: renamed from: c0, reason: collision with root package name */
    public Rect f4765c0;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4766d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f4767f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public int f4768g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public int f4769h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f4770i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f4771j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f4772k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public float f4773l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public float f4774m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public float f4775n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public String f4776o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public String f4777p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public ArrayList f4778q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public String f4779r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public ArrayList f4780s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public String f4781t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public ArrayList f4782u;
    public String v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public ArrayList f4783w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public String f4784x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public ArrayList f4785y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public String f4786z;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4762b = -1;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public int f4738D = -1;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public boolean f4739E = false;

    /* JADX INFO: renamed from: T, reason: collision with root package name */
    public final ArrayList f4753T = new ArrayList();

    /* JADX INFO: renamed from: U, reason: collision with root package name */
    public final ArrayList f4754U = new ArrayList();

    /* JADX INFO: renamed from: Y, reason: collision with root package name */
    public boolean f4758Y = true;

    /* JADX INFO: renamed from: a0, reason: collision with root package name */
    public boolean f4761a0 = true;

    public j(k kVar) {
        this.f4760a = kVar;
    }

    public static boolean a(j jVar, h hVar) {
        return (jVar.f4766d & hVar.f4730a) != 0;
    }

    public static CharSequence b(j jVar) {
        int i4 = 10;
        boolean z4 = false;
        C0053n c0053n = new C0053n(i4, z4);
        c0053n.f706b = jVar.f4779r;
        c0053n.f707c = jVar.f4780s;
        c0053n.f708d = jVar.d();
        SpannableString spannableStringE = c0053n.e();
        C0053n c0053n2 = new C0053n(i4, z4);
        c0053n2.f706b = jVar.f4777p;
        c0053n2.f707c = jVar.f4778q;
        c0053n2.e = jVar.f4735A;
        c0053n2.f708d = jVar.d();
        SpannableString spannableStringE2 = c0053n2.e();
        C0053n c0053n3 = new C0053n(i4, z4);
        c0053n3.f706b = jVar.f4784x;
        c0053n3.f707c = jVar.f4785y;
        c0053n3.f708d = jVar.d();
        CharSequence[] charSequenceArr = {spannableStringE, spannableStringE2, c0053n3.e()};
        CharSequence charSequenceConcat = null;
        for (int i5 = 0; i5 < 3; i5++) {
            CharSequence charSequence = charSequenceArr[i5];
            if (charSequence != null && charSequence.length() > 0) {
                charSequenceConcat = (charSequenceConcat == null || charSequenceConcat.length() == 0) ? charSequence : TextUtils.concat(charSequenceConcat, ", ", charSequence);
            }
        }
        return charSequenceConcat;
    }

    public static ArrayList f(ByteBuffer byteBuffer, ByteBuffer[] byteBufferArr) {
        int i4 = byteBuffer.getInt();
        if (i4 == -1) {
            return null;
        }
        ArrayList arrayList = new ArrayList(i4);
        for (int i5 = 0; i5 < i4; i5++) {
            int i6 = byteBuffer.getInt();
            int i7 = byteBuffer.getInt();
            int i8 = K.j.c(2)[byteBuffer.getInt()];
            int iB = K.j.b(i8);
            if (iB == 0) {
                byteBuffer.getInt();
                m mVar = new m();
                mVar.f4811a = i6;
                mVar.f4812b = i7;
                mVar.f4813c = i8;
                arrayList.add(mVar);
            } else if (iB == 1) {
                ByteBuffer byteBuffer2 = byteBufferArr[byteBuffer.getInt()];
                l lVar = new l();
                lVar.f4811a = i6;
                lVar.f4812b = i7;
                lVar.f4813c = i8;
                lVar.f4810d = StandardCharsets.UTF_8.decode(byteBuffer2).toString();
                arrayList.add(lVar);
            }
        }
        return arrayList;
    }

    public static void j(float[] fArr, float[] fArr2, float[] fArr3) {
        Matrix.multiplyMV(fArr, 0, fArr2, 0, fArr3, 0);
        float f4 = fArr[3];
        fArr[0] = fArr[0] / f4;
        fArr[1] = fArr[1] / f4;
        fArr[2] = fArr[2] / f4;
        fArr[3] = 0.0f;
    }

    public final void c(ArrayList arrayList) {
        if (g(12)) {
            arrayList.add(this);
        }
        Iterator it = this.f4753T.iterator();
        while (it.hasNext()) {
            ((j) it.next()).c(arrayList);
        }
    }

    public final String d() {
        String str = this.f4736B;
        return (str == null || str.isEmpty()) ? this.f4760a.f4799m : this.f4736B;
    }

    public final String e() {
        String str;
        if (g(13) && (str = this.f4777p) != null && !str.isEmpty()) {
            return this.f4777p;
        }
        Iterator it = this.f4753T.iterator();
        while (it.hasNext()) {
            String strE = ((j) it.next()).e();
            if (strE != null && !strE.isEmpty()) {
                return strE;
            }
        }
        return null;
    }

    public final boolean g(int i4) {
        return (this.f4764c & ((long) S.a(i4))) != 0;
    }

    public final j h(float[] fArr, boolean z4) {
        float f4 = fArr[3];
        boolean z5 = false;
        float f5 = fArr[0] / f4;
        float f6 = fArr[1] / f4;
        if (f5 < this.f4746M || f5 >= this.f4748O || f6 < this.f4747N || f6 >= this.f4749P) {
            return null;
        }
        float[] fArr2 = new float[4];
        for (j jVar : this.f4754U) {
            if (!jVar.g(14)) {
                if (jVar.f4758Y) {
                    jVar.f4758Y = false;
                    if (jVar.f4759Z == null) {
                        jVar.f4759Z = new float[16];
                    }
                    if (!Matrix.invertM(jVar.f4759Z, 0, jVar.f4751R, 0)) {
                        Arrays.fill(jVar.f4759Z, 0.0f);
                    }
                }
                float[] fArr3 = fArr;
                Matrix.multiplyMV(fArr2, 0, jVar.f4759Z, 0, fArr3, 0);
                j jVarH = jVar.h(fArr2, z4);
                if (jVarH != null) {
                    return jVarH;
                }
                fArr = fArr3;
            }
        }
        if (z4 && this.f4770i != -1) {
            z5 = true;
        }
        if (i() || z5) {
            return this;
        }
        return null;
    }

    public final boolean i() {
        if (g(12)) {
            return false;
        }
        if (g(22)) {
            return true;
        }
        if (g(32)) {
            return false;
        }
        int i4 = this.f4766d;
        int i5 = k.f4787y;
        if ((i4 & (-61)) != 0 || (this.f4764c & ((long) 10682871)) != 0) {
            return true;
        }
        String str = this.f4777p;
        if (str != null && !str.isEmpty()) {
            return true;
        }
        String str2 = this.f4779r;
        if (str2 != null && !str2.isEmpty()) {
            return true;
        }
        String str3 = this.f4784x;
        return (str3 == null || str3.isEmpty()) ? false : true;
    }

    public final void k(float[] fArr, HashSet hashSet, boolean z4) {
        hashSet.add(this);
        if (this.f4761a0) {
            z4 = true;
        }
        if (z4) {
            if (this.f4763b0 == null) {
                this.f4763b0 = new float[16];
            }
            if (this.f4750Q == null) {
                this.f4750Q = new float[16];
            }
            Matrix.multiplyMM(this.f4763b0, 0, fArr, 0, this.f4750Q, 0);
            float[] fArr2 = {this.f4746M, this.f4747N, 0.0f, 1.0f};
            float[] fArr3 = new float[4];
            float[] fArr4 = new float[4];
            float[] fArr5 = new float[4];
            float[] fArr6 = new float[4];
            j(fArr3, this.f4763b0, fArr2);
            fArr2[0] = this.f4748O;
            fArr2[1] = this.f4747N;
            j(fArr4, this.f4763b0, fArr2);
            fArr2[0] = this.f4748O;
            fArr2[1] = this.f4749P;
            j(fArr5, this.f4763b0, fArr2);
            fArr2[0] = this.f4746M;
            fArr2[1] = this.f4749P;
            j(fArr6, this.f4763b0, fArr2);
            if (this.f4765c0 == null) {
                this.f4765c0 = new Rect();
            }
            this.f4765c0.set(Math.round(Math.min(fArr3[0], Math.min(fArr4[0], Math.min(fArr5[0], fArr6[0])))), Math.round(Math.min(fArr3[1], Math.min(fArr4[1], Math.min(fArr5[1], fArr6[1])))), Math.round(Math.max(fArr3[0], Math.max(fArr4[0], Math.max(fArr5[0], fArr6[0])))), Math.round(Math.max(fArr3[1], Math.max(fArr4[1], Math.max(fArr5[1], fArr6[1])))));
            this.f4761a0 = false;
        }
        int i4 = -1;
        for (j jVar : this.f4753T) {
            jVar.f4738D = i4;
            i4 = jVar.f4762b;
            jVar.k(this.f4763b0, hashSet, z4);
        }
    }
}
