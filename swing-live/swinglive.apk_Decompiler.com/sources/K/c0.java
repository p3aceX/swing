package k;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class c0 extends H.c {
    public static final Parcelable.Creator<c0> CREATOR = new H.b(2);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f5341c;

    public c0(Parcel parcel, ClassLoader classLoader) {
        super(parcel, classLoader);
        this.f5341c = ((Boolean) parcel.readValue(null)).booleanValue();
    }

    public final String toString() {
        return "SearchView.SavedState{" + Integer.toHexString(System.identityHashCode(this)) + " isIconified=" + this.f5341c + "}";
    }

    @Override // H.c, android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        super.writeToParcel(parcel, i4);
        parcel.writeValue(Boolean.valueOf(this.f5341c));
    }
}
