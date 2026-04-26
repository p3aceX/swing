package X;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class A extends H.c {
    public static final Parcelable.Creator<A> CREATOR = new H.b(1);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Parcelable f2273c;

    public A(Parcel parcel, ClassLoader classLoader) {
        super(parcel, classLoader);
        this.f2273c = parcel.readParcelable(classLoader == null ? t.class.getClassLoader() : classLoader);
    }

    @Override // H.c, android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        super.writeToParcel(parcel, i4);
        parcel.writeParcelable(this.f2273c, 0);
    }
}
