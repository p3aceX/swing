package D0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.SparseArray;
import java.util.ArrayList;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class a extends A0.a {
    public static final Parcelable.Creator<a> CREATOR = new c(1);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f131a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashMap f132b = new HashMap();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final SparseArray f133c = new SparseArray();

    public a(int i4, ArrayList arrayList) {
        this.f131a = i4;
        int size = arrayList.size();
        for (int i5 = 0; i5 < size; i5++) {
            d dVar = (d) arrayList.get(i5);
            String str = dVar.f138b;
            int i6 = dVar.f139c;
            this.f132b.put(str, Integer.valueOf(i6));
            this.f133c.put(i6, str);
        }
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f131a);
        ArrayList arrayList = new ArrayList();
        HashMap map = this.f132b;
        for (String str : map.keySet()) {
            arrayList.add(new d(str, ((Integer) map.get(str)).intValue()));
        }
        AbstractC0184a.l0(parcel, 2, arrayList, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
