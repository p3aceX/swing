package k1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class m extends A0.a {
    public static final Parcelable.Creator<m> CREATOR = new C0511b(4);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final List f5536a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final List f5537b;

    public m(ArrayList arrayList, ArrayList arrayList2) {
        this.f5536a = arrayList == null ? new ArrayList() : arrayList;
        this.f5537b = arrayList2 == null ? new ArrayList() : arrayList2;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.l0(parcel, 1, this.f5536a, false);
        AbstractC0184a.l0(parcel, 2, this.f5537b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
