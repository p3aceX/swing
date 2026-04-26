package P0;

import O.O;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.s;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class e extends A0.a implements s {
    public static final Parcelable.Creator<e> CREATOR = new O(3);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f1483a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f1484b;

    public e(String str, ArrayList arrayList) {
        this.f1483a = arrayList;
        this.f1484b = str;
    }

    @Override // com.google.android.gms.common.api.s
    public final Status getStatus() {
        return this.f1484b != null ? Status.f3372f : Status.f3376p;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.j0(parcel, 1, this.f1483a);
        AbstractC0184a.i0(parcel, 2, this.f1484b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
