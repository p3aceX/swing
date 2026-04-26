package io.flutter.view;

import android.opengl.Matrix;
import android.os.Build;
import android.view.accessibility.AccessibilityEvent;
import android.widget.FrameLayout;
import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class e implements E2.j, E2.k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ Object f4703a;

    public /* synthetic */ e(Object obj) {
        this.f4703a = obj;
    }

    public void a(ByteBuffer byteBuffer, String[] strArr, ByteBuffer[] byteBufferArr) {
        int i4;
        int i5;
        io.flutter.plugin.platform.j jVar;
        ArrayList arrayList;
        int i6;
        int i7;
        j jVar2;
        int i8;
        int i9;
        j jVar3;
        String str;
        float f4;
        float f5;
        FrameLayout frameLayoutS;
        Integer num;
        k kVar;
        FrameLayout frameLayoutS2;
        byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
        for (ByteBuffer byteBuffer2 : byteBufferArr) {
            byteBuffer2.order(ByteOrder.LITTLE_ENDIAN);
        }
        k kVar2 = (k) this.f4703a;
        kVar2.getClass();
        ArrayList<j> arrayList2 = new ArrayList();
        while (true) {
            boolean zHasRemaining = byteBuffer.hasRemaining();
            i4 = 1;
            i5 = 14;
            jVar = kVar2.e;
            if (!zHasRemaining) {
                break;
            }
            j jVarC = kVar2.c(byteBuffer.getInt());
            jVarC.f4739E = true;
            jVarC.f4744K = jVarC.f4779r;
            jVarC.f4745L = jVarC.f4777p;
            jVarC.f4740F = jVarC.f4764c;
            jVarC.f4741G = jVarC.f4766d;
            jVarC.f4742H = jVarC.f4768g;
            jVarC.f4743I = jVarC.f4769h;
            jVarC.J = jVarC.f4773l;
            jVarC.f4764c = byteBuffer.getLong();
            jVarC.f4766d = byteBuffer.getInt();
            jVarC.e = byteBuffer.getInt();
            jVarC.f4767f = byteBuffer.getInt();
            jVarC.f4768g = byteBuffer.getInt();
            jVarC.f4769h = byteBuffer.getInt();
            jVarC.f4770i = byteBuffer.getInt();
            jVarC.f4771j = byteBuffer.getInt();
            jVarC.f4772k = byteBuffer.getInt();
            byteBuffer.getInt();
            jVarC.f4773l = byteBuffer.getFloat();
            jVarC.f4774m = byteBuffer.getFloat();
            jVarC.f4775n = byteBuffer.getFloat();
            jVarC.f4776o = k.d(byteBuffer, strArr);
            jVarC.f4777p = k.d(byteBuffer, strArr);
            jVarC.f4778q = j.f(byteBuffer, byteBufferArr);
            jVarC.f4779r = k.d(byteBuffer, strArr);
            jVarC.f4780s = j.f(byteBuffer, byteBufferArr);
            jVarC.f4781t = k.d(byteBuffer, strArr);
            jVarC.f4782u = j.f(byteBuffer, byteBufferArr);
            jVarC.v = k.d(byteBuffer, strArr);
            jVarC.f4783w = j.f(byteBuffer, byteBufferArr);
            jVarC.f4784x = k.d(byteBuffer, strArr);
            jVarC.f4785y = j.f(byteBuffer, byteBufferArr);
            jVarC.f4786z = k.d(byteBuffer, strArr);
            jVarC.f4735A = k.d(byteBuffer, strArr);
            jVarC.f4736B = k.d(byteBuffer, strArr);
            jVarC.f4737C = byteBuffer.getInt();
            byteBuffer.getInt();
            jVarC.f4746M = byteBuffer.getFloat();
            jVarC.f4747N = byteBuffer.getFloat();
            jVarC.f4748O = byteBuffer.getFloat();
            jVarC.f4749P = byteBuffer.getFloat();
            float[] fArr = jVarC.f4750Q;
            if (fArr == null) {
                fArr = new float[16];
            }
            for (int i10 = 0; i10 < 16; i10++) {
                fArr[i10] = byteBuffer.getFloat();
            }
            jVarC.f4750Q = fArr;
            float[] fArr2 = jVarC.f4751R;
            if (fArr2 == null) {
                fArr2 = new float[16];
            }
            for (int i11 = 0; i11 < 16; i11++) {
                fArr2[i11] = byteBuffer.getFloat();
            }
            jVarC.f4751R = fArr2;
            jVarC.f4758Y = true;
            jVarC.f4761a0 = true;
            int i12 = byteBuffer.getInt();
            ArrayList arrayList3 = jVarC.f4753T;
            arrayList3.clear();
            int i13 = 0;
            while (true) {
                kVar = jVarC.f4760a;
                if (i13 >= i12) {
                    break;
                }
                j jVarC2 = kVar.c(byteBuffer.getInt());
                jVarC2.f4752S = jVarC;
                arrayList3.add(jVarC2);
                i13++;
            }
            int i14 = byteBuffer.getInt();
            ArrayList arrayList4 = jVarC.f4754U;
            arrayList4.clear();
            for (int i15 = 0; i15 < i14; i15++) {
                j jVarC3 = kVar.c(byteBuffer.getInt());
                jVarC3.f4752S = jVarC;
                arrayList4.add(jVarC3);
            }
            int i16 = byteBuffer.getInt();
            if (i16 == 0) {
                jVarC.f4755V = null;
            } else {
                ArrayList arrayList5 = jVarC.f4755V;
                if (arrayList5 == null) {
                    jVarC.f4755V = new ArrayList(i16);
                } else {
                    arrayList5.clear();
                }
                for (int i17 = 0; i17 < i16; i17++) {
                    i iVarB = kVar.b(byteBuffer.getInt());
                    int i18 = iVarB.f4733c;
                    if (i18 == 1) {
                        jVarC.f4756W = iVarB;
                    } else if (i18 == 2) {
                        jVarC.f4757X = iVarB;
                    } else {
                        jVarC.f4755V.add(iVarB);
                    }
                    jVarC.f4755V.add(iVarB);
                }
            }
            if (!jVarC.g(14)) {
                if (jVarC.g(6)) {
                    kVar2.f4800n = jVarC;
                }
                if (jVarC.f4739E) {
                    arrayList2.add(jVarC);
                }
                int i19 = jVarC.f4770i;
                if (i19 != -1 && !jVar.m(i19) && (frameLayoutS2 = jVar.s(jVarC.f4770i)) != null) {
                    frameLayoutS2.setImportantForAccessibility(0);
                }
            }
        }
        HashSet hashSet = new HashSet();
        HashMap map = kVar2.f4793g;
        j jVar4 = (j) map.get(0);
        ArrayList arrayList6 = new ArrayList();
        if (jVar4 != null) {
            float[] fArr3 = new float[16];
            Matrix.setIdentityM(fArr3, 0);
            jVar4.k(fArr3, hashSet, false);
            jVar4.c(arrayList6);
        }
        Iterator it = arrayList6.iterator();
        j jVar5 = null;
        while (true) {
            boolean zHasNext = it.hasNext();
            arrayList = kVar2.f4803q;
            if (!zHasNext) {
                break;
            }
            j jVar6 = (j) it.next();
            if (!arrayList.contains(Integer.valueOf(jVar6.f4762b))) {
                jVar5 = jVar6;
            }
        }
        if (jVar5 == null && !arrayList6.isEmpty()) {
            jVar5 = (j) arrayList6.get(arrayList6.size() - 1);
        }
        if (jVar5 != null && (jVar5.f4762b != kVar2.f4804r || arrayList6.size() != arrayList.size())) {
            kVar2.f4804r = jVar5.f4762b;
            String strE = jVar5.e();
            if (strE == null) {
                strE = " ";
            }
            if (Build.VERSION.SDK_INT >= 28) {
                kVar2.f4788a.setAccessibilityPaneTitle(strE);
            } else {
                AccessibilityEvent accessibilityEventE = kVar2.e(jVar5.f4762b, 32);
                accessibilityEventE.getText().add(strE);
                kVar2.i(accessibilityEventE);
            }
        }
        arrayList.clear();
        Iterator it2 = arrayList6.iterator();
        while (it2.hasNext()) {
            arrayList.add(Integer.valueOf(((j) it2.next()).f4762b));
        }
        Iterator it3 = map.entrySet().iterator();
        while (true) {
            i6 = 4;
            if (!it3.hasNext()) {
                break;
            }
            j jVar7 = (j) ((Map.Entry) it3.next()).getValue();
            if (!hashSet.contains(jVar7)) {
                jVar7.f4752S = null;
                if (jVar7.f4770i != -1 && (num = kVar2.f4796j) != null && kVar2.f4791d.platformViewOfNode(num.intValue()) == jVar.s(jVar7.f4770i)) {
                    kVar2.h(kVar2.f4796j.intValue(), 65536);
                    kVar2.f4796j = null;
                }
                int i20 = jVar7.f4770i;
                if (i20 != -1 && (frameLayoutS = jVar.s(i20)) != null) {
                    frameLayoutS.setImportantForAccessibility(4);
                }
                j jVar8 = kVar2.f4795i;
                if (jVar8 == jVar7) {
                    kVar2.h(jVar8.f4762b, 65536);
                    kVar2.f4795i = null;
                }
                if (kVar2.f4800n == jVar7) {
                    kVar2.f4800n = null;
                }
                if (kVar2.f4802p == jVar7) {
                    kVar2.f4802p = null;
                }
                it3.remove();
            }
        }
        int i21 = 2048;
        int i22 = 0;
        AccessibilityEvent accessibilityEventE2 = kVar2.e(0, 2048);
        accessibilityEventE2.setContentChangeTypes(1);
        kVar2.i(accessibilityEventE2);
        for (j jVar9 : arrayList2) {
            if (!Float.isNaN(jVar9.f4773l) && !Float.isNaN(jVar9.J) && jVar9.J != jVar9.f4773l) {
                AccessibilityEvent accessibilityEventE3 = kVar2.e(jVar9.f4762b, 4096);
                float f6 = jVar9.f4773l;
                float f7 = jVar9.f4774m;
                if (Float.isInfinite(f7)) {
                    if (f6 > 70000.0f) {
                        f6 = 70000.0f;
                    }
                    f7 = 100000.0f;
                }
                if (Float.isInfinite(jVar9.f4775n)) {
                    f4 = f7 + 100000.0f;
                    if (f6 < -70000.0f) {
                        f6 = -70000.0f;
                    }
                    f5 = f6 + 100000.0f;
                } else {
                    float f8 = jVar9.f4775n;
                    f4 = f7 - f8;
                    f5 = f6 - f8;
                }
                int i23 = jVar9.f4741G;
                if ((i23 & 16) != 0 || (i23 & 32) != 0) {
                    accessibilityEventE3.setScrollY((int) f5);
                    accessibilityEventE3.setMaxScrollY((int) f4);
                } else if ((i23 & 4) != 0 || (i23 & 8) != 0) {
                    accessibilityEventE3.setScrollX((int) f5);
                    accessibilityEventE3.setMaxScrollX((int) f4);
                }
                int i24 = jVar9.f4771j;
                if (i24 > 0) {
                    accessibilityEventE3.setItemCount(i24);
                    accessibilityEventE3.setFromIndex(jVar9.f4772k);
                    Iterator it4 = jVar9.f4754U.iterator();
                    int i25 = i22;
                    while (it4.hasNext()) {
                        if (!((j) it4.next()).g(i5)) {
                            i25++;
                        }
                    }
                    accessibilityEventE3.setToIndex((jVar9.f4772k + i25) - i4);
                }
                kVar2.i(accessibilityEventE3);
            }
            if (jVar9.g(16) && (((str = jVar9.f4777p) != null || jVar9.f4745L != null) && (str == null || !str.equals(jVar9.f4745L)))) {
                AccessibilityEvent accessibilityEventE4 = kVar2.e(jVar9.f4762b, i21);
                accessibilityEventE4.setContentChangeTypes(i4);
                kVar2.i(accessibilityEventE4);
            }
            j jVar10 = kVar2.f4795i;
            if (jVar10 != null && jVar10.f4762b == jVar9.f4762b) {
                if ((((long) S.a(3)) & jVar9.f4740F) == 0 && jVar9.g(3)) {
                    AccessibilityEvent accessibilityEventE5 = kVar2.e(jVar9.f4762b, i6);
                    accessibilityEventE5.getText().add(jVar9.f4777p);
                    kVar2.i(accessibilityEventE5);
                }
            }
            j jVar11 = kVar2.f4800n;
            if (jVar11 != null && (i8 = jVar11.f4762b) == (i9 = jVar9.f4762b) && ((jVar3 = kVar2.f4801o) == null || jVar3.f4762b != i8)) {
                kVar2.f4801o = jVar11;
                kVar2.i(kVar2.e(i9, 8));
            } else if (jVar11 == null) {
                kVar2.f4801o = null;
            }
            j jVar12 = kVar2.f4800n;
            if (jVar12 == null || jVar12.f4762b != jVar9.f4762b) {
                i7 = i4;
            } else {
                i7 = i4;
                if ((jVar9.f4740F & ((long) S.a(5))) != 0 && jVar9.g(5) && ((jVar2 = kVar2.f4795i) == null || jVar2.f4762b == kVar2.f4800n.f4762b)) {
                    String str2 = jVar9.f4744K;
                    if (str2 == null) {
                        str2 = "";
                    }
                    String str3 = jVar9.f4779r;
                    String str4 = str3 != null ? str3 : "";
                    AccessibilityEvent accessibilityEventE6 = kVar2.e(jVar9.f4762b, 16);
                    accessibilityEventE6.setBeforeText(str2);
                    accessibilityEventE6.getText().add(str4);
                    int i26 = 0;
                    while (i26 < str2.length() && i26 < str4.length() && str2.charAt(i26) == str4.charAt(i26)) {
                        i26++;
                    }
                    if (i26 < str2.length() || i26 < str4.length()) {
                        accessibilityEventE6.setFromIndex(i26);
                        int length = str2.length() - i7;
                        int length2 = str4.length() - i7;
                        while (length >= i26 && length2 >= i26 && str2.charAt(length) == str4.charAt(length2)) {
                            length--;
                            length2--;
                        }
                        accessibilityEventE6.setRemovedCount((length - i26) + i7);
                        accessibilityEventE6.setAddedCount((length2 - i26) + i7);
                    } else {
                        accessibilityEventE6 = null;
                    }
                    if (accessibilityEventE6 != null) {
                        kVar2.i(accessibilityEventE6);
                    }
                    if (jVar9.f4742H != jVar9.f4768g || jVar9.f4743I != jVar9.f4769h) {
                        AccessibilityEvent accessibilityEventE7 = kVar2.e(jVar9.f4762b, 8192);
                        accessibilityEventE7.getText().add(str4);
                        accessibilityEventE7.setFromIndex(jVar9.f4768g);
                        accessibilityEventE7.setToIndex(jVar9.f4769h);
                        accessibilityEventE7.setItemCount(str4.length());
                        kVar2.i(accessibilityEventE7);
                    }
                }
                i4 = i7;
                i21 = 2048;
                i22 = 0;
                i6 = 4;
                i5 = 14;
            }
            i4 = i7;
            i21 = 2048;
            i22 = 0;
            i6 = 4;
            i5 = 14;
        }
    }
}
