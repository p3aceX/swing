package k1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class g extends A0.a {
    public static final Parcelable.Creator<g> CREATOR = new C0511b(3);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f5526a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public String f5527b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public ArrayList f5528c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ArrayList f5529d;
    public e e;

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5526a, false);
        AbstractC0184a.i0(parcel, 2, this.f5527b, false);
        AbstractC0184a.l0(parcel, 3, this.f5528c, false);
        AbstractC0184a.l0(parcel, 4, this.f5529d, false);
        AbstractC0184a.h0(parcel, 5, this.e, i4, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
