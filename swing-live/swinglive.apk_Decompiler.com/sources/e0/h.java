package E0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class h extends A0.a {
    public static final Parcelable.Creator<h> CREATOR = new D0.c(4);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f300a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashMap f301b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f302c;

    public h(int i4, String str, ArrayList arrayList) {
        this.f300a = i4;
        HashMap map = new HashMap();
        int size = arrayList.size();
        for (int i5 = 0; i5 < size; i5++) {
            f fVar = (f) arrayList.get(i5);
            String str2 = fVar.f295b;
            HashMap map2 = new HashMap();
            ArrayList arrayList2 = fVar.f296c;
            F.g(arrayList2);
            int size2 = arrayList2.size();
            for (int i6 = 0; i6 < size2; i6++) {
                g gVar = (g) arrayList2.get(i6);
                map2.put(gVar.f298b, gVar.f299c);
            }
            map.put(str2, map2);
        }
        this.f301b = map;
        F.g(str);
        this.f302c = str;
        Iterator it = map.keySet().iterator();
        while (it.hasNext()) {
            Map map3 = (Map) map.get((String) it.next());
            Iterator it2 = map3.keySet().iterator();
            while (it2.hasNext()) {
                ((a) map3.get((String) it2.next())).f286p = this;
            }
        }
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder();
        HashMap map = this.f301b;
        for (String str : map.keySet()) {
            sb.append(str);
            sb.append(":\n");
            Map map2 = (Map) map.get(str);
            for (String str2 : map2.keySet()) {
                sb.append("  ");
                sb.append(str2);
                sb.append(": ");
                sb.append(map2.get(str2));
            }
        }
        return sb.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f300a);
        ArrayList arrayList = new ArrayList();
        HashMap map = this.f301b;
        for (String str : map.keySet()) {
            arrayList.add(new f(str, (Map) map.get(str)));
        }
        AbstractC0184a.l0(parcel, 2, arrayList, false);
        AbstractC0184a.i0(parcel, 3, this.f302c, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
