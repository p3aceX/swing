package o3;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import q3.AbstractC0643h;
import q3.C0637b;
import q3.C0644i;
import u3.AbstractC0692a;

/* JADX INFO: loaded from: classes.dex */
public final class O {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f6029a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final List f6030b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0594b f6031c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f6032d;

    public O(W w4, byte[] bArr, byte[] bArr2, short s4, List list) throws C0590F {
        Object next;
        J3.i.e(w4, "version");
        J3.i.e(list, "extensions");
        this.f6029a = bArr;
        this.f6030b = list;
        Iterator it = AbstractC0593a.f6065a.iterator();
        while (true) {
            if (it.hasNext()) {
                next = it.next();
                if (((C0594b) next).f6066a == s4) {
                    break;
                }
            } else {
                next = null;
                break;
            }
        }
        C0594b c0594b = (C0594b) next;
        if (c0594b == null) {
            throw new IllegalStateException(("Server cipher suite is not supported: " + ((int) s4)).toString());
        }
        this.f6031c = c0594b;
        ArrayList arrayList = new ArrayList();
        for (C0644i c0644i : this.f6030b) {
            if (N.f6028a[c0644i.f6298a.ordinal()] == 1) {
                List list2 = AbstractC0643h.f6297a;
                Z3.a aVar = c0644i.f6299b;
                int iB = aVar.b() & 65535;
                ArrayList arrayList2 = new ArrayList();
                while (AbstractC0692a.a(aVar) > 0) {
                    C0637b c0637bA = AbstractC0643h.a(aVar.readByte(), aVar.readByte());
                    if (c0637bA != null) {
                        arrayList2.add(c0637bA);
                    }
                }
                if (((int) AbstractC0692a.a(aVar)) != iB) {
                    StringBuilder sbI = com.google.crypto.tink.shaded.protobuf.S.i("Invalid hash and sign packet size: expected ", iB, ", actual ");
                    sbI.append(arrayList2.size());
                    throw new C0590F(sbI.toString(), 0);
                }
                arrayList.addAll(arrayList2);
            }
        }
        this.f6032d = arrayList;
    }
}
