package f0;

import I3.l;
import J3.i;
import K.j;
import android.util.Log;
import e1.AbstractC0367g;
import e1.k;
import java.util.ArrayList;
import java.util.Collection;
import x3.AbstractC0726f;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public final class f extends AbstractC0367g {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f4274c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f4275d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final B2.a f4276f;

    public f(Object obj, String str, C0399a c0399a, int i4) {
        Collection collectionX;
        i.e(obj, "value");
        B1.a.o(i4, "verificationMode");
        this.f4274c = obj;
        this.f4275d = str;
        this.e = i4;
        String strM = AbstractC0367g.m(obj, str);
        i.e(strM, "message");
        B2.a aVar = new B2.a(strM);
        StackTraceElement[] stackTrace = aVar.getStackTrace();
        i.d(stackTrace, "stackTrace");
        int length = stackTrace.length - 2;
        length = length < 0 ? 0 : length;
        if (length < 0) {
            throw new IllegalArgumentException(B1.a.l("Requested element count ", length, " is less than zero.").toString());
        }
        if (length == 0) {
            collectionX = p.f6784a;
        } else {
            int length2 = stackTrace.length;
            if (length >= length2) {
                collectionX = AbstractC0726f.n0(stackTrace);
            } else if (length == 1) {
                collectionX = k.x(stackTrace[length2 - 1]);
            } else {
                ArrayList arrayList = new ArrayList(length);
                for (int i5 = length2 - length; i5 < length2; i5++) {
                    arrayList.add(stackTrace[i5]);
                }
                collectionX = arrayList;
            }
        }
        aVar.setStackTrace((StackTraceElement[]) collectionX.toArray(new StackTraceElement[0]));
        this.f4276f = aVar;
    }

    @Override // e1.AbstractC0367g
    public final Object d() throws B2.a {
        int iB = j.b(this.e);
        if (iB == 0) {
            throw this.f4276f;
        }
        if (iB != 1) {
            if (iB == 2) {
                return null;
            }
            throw new A0.b();
        }
        String strM = AbstractC0367g.m(this.f4274c, this.f4275d);
        i.e(strM, "message");
        Log.d("f", strM);
        return null;
    }

    @Override // e1.AbstractC0367g
    public final AbstractC0367g J(String str, l lVar) {
        return this;
    }
}
