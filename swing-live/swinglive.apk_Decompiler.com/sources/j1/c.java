package J1;

import J3.i;
import K.j;
import K.k;
import X.B;
import android.content.Context;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.view.View;
import androidx.recyclerview.widget.RecyclerView;
import java.io.Serializable;
import java.nio.Buffer;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicBoolean;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f783a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f784b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f785c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Object f786d;
    public Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Serializable f787f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final Object f788g;

    public c() {
        this.f785c = new b();
        this.f786d = new e();
        this.f787f = new ArrayList();
        this.f788g = new AtomicBoolean(false);
    }

    public void a(boolean z4) {
        b bVar;
        ArrayList arrayList = (ArrayList) this.f787f;
        ArrayList<K1.a> arrayList2 = new ArrayList();
        for (Object obj : arrayList) {
            K1.a aVar = (K1.a) obj;
            if (z4) {
                if (aVar.f851k != d.f790b) {
                    arrayList2.add(obj);
                }
            } else if (aVar.f851k != d.f789a) {
                arrayList2.add(obj);
            }
        }
        int size = arrayList2.size();
        int i4 = 0;
        while (true) {
            bVar = (b) this.f785c;
            if (i4 >= size) {
                break;
            }
            ((K1.a) arrayList2.get(i4)).f849i = i4 == 0 ? ((int[]) bVar.f771d.f6833d)[0] : ((K1.a) arrayList2.get(i4 - 1)).e();
            i4++;
        }
        ((e) this.f786d).f796d = arrayList2.isEmpty() ? ((int[]) bVar.f771d.f6833d)[0] : ((K1.a) arrayList2.get(arrayList2.size() - 1)).e();
        for (K1.a aVar2 : arrayList2) {
            GLES20.glBindFramebuffer(36160, ((int[]) aVar2.f850j.f6831b)[0]);
            GLES20.glViewport(0, 0, aVar2.f847g, aVar2.f848h);
            aVar2.d();
            GLES20.glDrawArrays(5, 0, 4);
            aVar2.c();
            GLES20.glBindFramebuffer(36160, 0);
        }
    }

    public void b(int i4, int i5, O1.a aVar, int i6, boolean z4, boolean z5) {
        int i7;
        int i8;
        int i9;
        int i10;
        int i11;
        int i12;
        int i13;
        N1.a aVar2;
        int i14 = i5;
        i.e(aVar, "mode");
        e eVar = (e) this.f786d;
        eVar.getClass();
        float f4 = z5 ? -1.0f : 1.0f;
        float f5 = z4 ? -1.0f : 1.0f;
        float[] fArr = eVar.f794b;
        Matrix.setIdentityM(fArr, 0);
        Matrix.scaleM(fArr, 0, f4, f5, 1.0f);
        Matrix.rotateM(fArr, 0, i6, 0.0f, 0.0f, -1.0f);
        int i15 = eVar.f802k;
        int i16 = eVar.f803l;
        if (aVar == O1.a.f1444b) {
            aVar2 = new N1.a(0, 0, i4, i14);
        } else {
            float f6 = i15 / i16;
            float f7 = i4 / i14;
            if (aVar == O1.a.f1443a) {
                if (f6 > f7) {
                    i7 = (i16 * i4) / i15;
                    i8 = (i7 - i14) / (-2);
                    i12 = i4;
                    i13 = i8;
                    i14 = i7;
                    i11 = 0;
                } else {
                    i9 = (i15 * i14) / i16;
                    i10 = (i9 - i4) / (-2);
                    i11 = i10;
                    i12 = i9;
                    i13 = 0;
                }
            } else if (f6 > f7) {
                i9 = (i15 * i14) / i16;
                i10 = (i9 - i4) / (-2);
                i11 = i10;
                i12 = i9;
                i13 = 0;
            } else {
                i7 = (i16 * i4) / i15;
                i8 = (i7 - i14) / (-2);
                i12 = i4;
                i13 = i8;
                i14 = i7;
                i11 = 0;
            }
            aVar2 = new N1.a(i11, i13, i12, i14);
        }
        GLES20.glViewport(aVar2.f1125a, aVar2.f1126b, aVar2.f1127c, aVar2.f1128d);
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        GLES20.glClear(16640);
        GLES20.glUseProgram(eVar.e);
        FloatBuffer floatBuffer = eVar.f793a;
        floatBuffer.position(0);
        GLES20.glVertexAttribPointer(eVar.f799h, 3, 5126, false, 20, (Buffer) eVar.f793a);
        GLES20.glEnableVertexAttribArray(eVar.f799h);
        floatBuffer.position(3);
        GLES20.glVertexAttribPointer(eVar.f800i, 2, 5126, false, 20, (Buffer) eVar.f793a);
        GLES20.glEnableVertexAttribArray(eVar.f800i);
        GLES20.glUniformMatrix4fv(eVar.f797f, 1, false, fArr, 0);
        GLES20.glUniformMatrix4fv(eVar.f798g, 1, false, eVar.f795c, 0);
        GLES20.glUniform1i(eVar.f801j, 0);
        GLES20.glActiveTexture(33984);
        GLES20.glBindTexture(3553, eVar.f796d);
        GLES20.glDrawArrays(5, 0, 4);
        H0.a.w(eVar.f800i, eVar.f799h);
    }

    public void c(K1.a aVar) {
        ArrayList arrayList = (ArrayList) this.f787f;
        int i4 = ((K1.a) arrayList.get(0)).f849i;
        C0747k c0747k = ((K1.a) arrayList.get(0)).f850j;
        ((K1.a) arrayList.get(0)).b();
        arrayList.set(0, aVar);
        ((K1.a) arrayList.get(0)).f849i = i4;
        K1.a aVar2 = (K1.a) arrayList.get(0);
        int i5 = this.f783a;
        int i6 = this.f784b;
        Context context = (Context) this.e;
        aVar2.f847g = i5;
        aVar2.f848h = i6;
        aVar2.f(context);
        ((K1.a) arrayList.get(0)).f850j = c0747k;
    }

    public void d(K1.a aVar) {
        B1.a.o(1, "filterAction");
        i.e(aVar, "baseFilterRender");
        int iB = j.b(1);
        ArrayList arrayList = (ArrayList) this.f787f;
        switch (iB) {
            case 0:
                if (arrayList.size() > 0) {
                    c(aVar);
                    return;
                }
                ((ArrayList) this.f787f).add(aVar);
                int i4 = this.f783a;
                int i5 = this.f784b;
                Context context = (Context) this.e;
                aVar.f847g = i4;
                aVar.f848h = i5;
                aVar.f(context);
                int i6 = aVar.f847g;
                int i7 = aVar.f848h;
                C0747k c0747k = aVar.f850j;
                a.a(i6, i7, (int[]) c0747k.f6831b, (int[]) c0747k.f6832c, (int[]) c0747k.f6833d);
                return;
            case 1:
                c(aVar);
                return;
            case 2:
                arrayList.add(aVar);
                int i8 = this.f783a;
                int i9 = this.f784b;
                Context context2 = (Context) this.e;
                aVar.f847g = i8;
                aVar.f848h = i9;
                aVar.f(context2);
                int i10 = aVar.f847g;
                int i11 = aVar.f848h;
                C0747k c0747k2 = aVar.f850j;
                a.a(i10, i11, (int[]) c0747k2.f6831b, (int[]) c0747k2.f6832c, (int[]) c0747k2.f6833d);
                return;
            case 3:
                arrayList.add(0, aVar);
                int i12 = this.f783a;
                int i13 = this.f784b;
                Context context3 = (Context) this.e;
                aVar.f847g = i12;
                aVar.f848h = i13;
                aVar.f(context3);
                int i14 = aVar.f847g;
                int i15 = aVar.f848h;
                C0747k c0747k3 = aVar.f850j;
                a.a(i14, i15, (int[]) c0747k3.f6831b, (int[]) c0747k3.f6832c, (int[]) c0747k3.f6833d);
                return;
            case 4:
                Iterator it = arrayList.iterator();
                while (it.hasNext()) {
                    ((K1.a) it.next()).b();
                }
                arrayList.clear();
                return;
            case 5:
                aVar.b();
                arrayList.remove(aVar);
                return;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                ((K1.a) arrayList.remove(0)).b();
                return;
            default:
                throw new A0.b();
        }
    }

    public void e(int i4) {
        RecyclerView recyclerView = (RecyclerView) this.f788g;
        B b5 = recyclerView.f3162d0;
        if (i4 < 0 || i4 >= b5.a()) {
            throw new IndexOutOfBoundsException("Invalid item position " + i4 + "(" + i4 + "). Item count:" + b5.a() + recyclerView.h());
        }
        boolean z4 = b5.f2276c;
        ArrayList arrayList = (ArrayList) this.f787f;
        if (arrayList.size() > 0) {
            arrayList.get(0).getClass();
            throw new ClassCastException();
        }
        ArrayList arrayList2 = (ArrayList) recyclerView.f3161d.f6833d;
        if (arrayList2.size() > 0) {
            RecyclerView.j((View) arrayList2.get(0));
            throw null;
        }
        ArrayList arrayList3 = (ArrayList) this.f785c;
        if (arrayList3.size() > 0) {
            arrayList3.get(0).getClass();
            throw new ClassCastException();
        }
        int iC = recyclerView.f3159c.C(i4, 0);
        if (iC >= 0) {
            throw null;
        }
        throw new IndexOutOfBoundsException("Inconsistency detected. Invalid item position " + i4 + "(offset:" + iC + ").state:" + b5.a() + recyclerView.h());
    }

    public void f() {
        this.f784b = this.f783a;
        ArrayList arrayList = (ArrayList) this.f785c;
        int size = arrayList.size() - 1;
        if (size < 0 || arrayList.size() <= this.f784b) {
            return;
        }
        if (arrayList.get(size) != null) {
            throw new ClassCastException();
        }
        int[] iArr = RecyclerView.n0;
        throw null;
    }

    public c(Integer num, int i4, Boolean bool, Integer num2, int i5, Integer num3, Boolean bool2) {
        this.f785c = num;
        this.f783a = i4;
        this.f786d = bool;
        this.e = num2;
        this.f784b = i5;
        this.f787f = num3;
        this.f788g = bool2;
    }

    public c(RecyclerView recyclerView) {
        this.f788g = recyclerView;
        ArrayList arrayList = new ArrayList();
        this.f787f = arrayList;
        this.f785c = new ArrayList();
        this.f786d = Collections.unmodifiableList(arrayList);
        this.f783a = 2;
        this.f784b = 2;
    }
}
