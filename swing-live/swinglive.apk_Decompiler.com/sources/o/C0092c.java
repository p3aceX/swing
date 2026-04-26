package O;

import android.os.Parcel;
import android.os.Parcelable;
import java.util.ArrayList;

/* JADX INFO: renamed from: O.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0092c implements Parcelable {
    public static final Parcelable.Creator<C0092c> CREATOR = new M0.W(28);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f1335a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f1336b;

    public C0092c(Parcel parcel) {
        this.f1335a = parcel.createStringArrayList();
        this.f1336b = parcel.createTypedArrayList(C0091b.CREATOR);
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeStringList(this.f1335a);
        parcel.writeTypedList(this.f1336b);
    }
}
