package v2;

import J3.i;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import x3.AbstractC0728h;
import x3.AbstractC0730j;

/* JADX INFO: loaded from: classes.dex */
public final class c extends Q.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6668b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f6669c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f6670d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final String f6671f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public c(int i4, int i5, String str) {
        super(3);
        i.e(str, "path");
        this.f6668b = "1.5.3";
        this.f6669c = 63;
        this.f6670d = i4;
        this.e = i5;
        this.f6671f = str;
    }

    public static byte[] k(List list) {
        ArrayList arrayListN0 = AbstractC0728h.n0(list, 4, 4);
        ArrayList arrayList = new ArrayList();
        ArrayList arrayList2 = new ArrayList(AbstractC0730j.V(arrayListN0));
        Iterator it = arrayListN0.iterator();
        while (it.hasNext()) {
            arrayList2.add(AbstractC0728h.d0((List) it.next()));
        }
        Iterator it2 = arrayList2.iterator();
        while (it2.hasNext()) {
            arrayList.addAll((List) it2.next());
        }
        return AbstractC0728h.f0(arrayList);
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof c)) {
            return false;
        }
        c cVar = (c) obj;
        return i.a(this.f6668b, cVar.f6668b) && this.f6669c == cVar.f6669c && this.f6670d == cVar.f6670d && this.e == cVar.e && i.a(this.f6671f, cVar.f6671f);
    }

    public final int hashCode() {
        return (this.f6671f.hashCode() + B1.a.h(this.e, B1.a.h(this.f6670d, B1.a.h(this.f6669c, this.f6668b.hashCode() * 31, 31), 31), 31)) * 31;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("HandshakeExtension(version=");
        sb.append(this.f6668b);
        sb.append(", flags=");
        sb.append(this.f6669c);
        sb.append(", receiverDelay=");
        sb.append(this.f6670d);
        sb.append(", senderDelay=");
        sb.append(this.e);
        sb.append(", path=");
        return S.h(sb, this.f6671f, ", encryptInfo=null)");
    }
}
