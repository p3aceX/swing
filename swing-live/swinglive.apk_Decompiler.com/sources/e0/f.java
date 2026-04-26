package E0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class f extends A0.a {
    public static final Parcelable.Creator<f> CREATOR = new D0.c(5);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f294a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f295b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ArrayList f296c;

    public f(int i4, String str, ArrayList arrayList) {
        this.f294a = i4;
        this.f295b = str;
        this.f296c = arrayList;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f294a);
        AbstractC0184a.i0(parcel, 2, this.f295b, false);
        AbstractC0184a.l0(parcel, 3, this.f296c, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    public f(String str, Map map) {
        ArrayList arrayList;
        this.f294a = 1;
        this.f295b = str;
        if (map == null) {
            arrayList = null;
        } else {
            arrayList = new ArrayList();
            for (String str2 : map.keySet()) {
                arrayList.add(new g((a) map.get(str2), str2));
            }
        }
        this.f296c = arrayList;
    }
}
