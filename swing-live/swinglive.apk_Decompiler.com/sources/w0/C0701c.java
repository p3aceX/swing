package w0;

import android.app.PendingIntent;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.internal.SignInConfiguration;
import y0.C0737a;
import z0.C0771b;
import z0.C0773d;

/* JADX INFO: renamed from: w0.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0701c implements Parcelable.Creator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6693a;

    public /* synthetic */ C0701c(int i4) {
        this.f6693a = i4;
    }

    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        switch (this.f6693a) {
            case 0:
                int iI0 = H0.a.i0(parcel);
                String strQ = null;
                byte[] bArrJ = null;
                Bundle bundleI = null;
                long jW = 0;
                int iU = 0;
                int iU2 = 0;
                while (parcel.dataPosition() < iI0) {
                    int i4 = parcel.readInt();
                    char c5 = (char) i4;
                    if (c5 == 1) {
                        strQ = H0.a.q(i4, parcel);
                    } else if (c5 == 2) {
                        iU2 = H0.a.U(i4, parcel);
                    } else if (c5 == 3) {
                        jW = H0.a.W(i4, parcel);
                    } else if (c5 == 4) {
                        bArrJ = H0.a.j(i4, parcel);
                    } else if (c5 == 5) {
                        bundleI = H0.a.i(i4, parcel);
                    } else if (c5 != 1000) {
                        H0.a.e0(i4, parcel);
                    } else {
                        iU = H0.a.U(i4, parcel);
                    }
                }
                H0.a.y(iI0, parcel);
                return new C0699a(iU, strQ, iU2, jW, bArrJ, bundleI);
            case 1:
                int iI02 = H0.a.i0(parcel);
                PendingIntent pendingIntent = null;
                Bundle bundleI2 = null;
                byte[] bArrJ2 = null;
                int iU3 = 0;
                int iU4 = 0;
                int iU5 = 0;
                while (parcel.dataPosition() < iI02) {
                    int i5 = parcel.readInt();
                    char c6 = (char) i5;
                    if (c6 == 1) {
                        iU4 = H0.a.U(i5, parcel);
                    } else if (c6 == 2) {
                        pendingIntent = (PendingIntent) H0.a.o(parcel, i5, PendingIntent.CREATOR);
                    } else if (c6 == 3) {
                        iU5 = H0.a.U(i5, parcel);
                    } else if (c6 == 4) {
                        bundleI2 = H0.a.i(i5, parcel);
                    } else if (c6 == 5) {
                        bArrJ2 = H0.a.j(i5, parcel);
                    } else if (c6 != 1000) {
                        H0.a.e0(i5, parcel);
                    } else {
                        iU3 = H0.a.U(i5, parcel);
                    }
                }
                H0.a.y(iI02, parcel);
                return new C0700b(iU3, iU4, pendingIntent, iU5, bundleI2, bArrJ2);
            case 2:
                int iI03 = H0.a.i0(parcel);
                int iU6 = 0;
                Bundle bundleI3 = null;
                int iU7 = 0;
                while (parcel.dataPosition() < iI03) {
                    int i6 = parcel.readInt();
                    char c7 = (char) i6;
                    if (c7 == 1) {
                        iU6 = H0.a.U(i6, parcel);
                    } else if (c7 == 2) {
                        iU7 = H0.a.U(i6, parcel);
                    } else if (c7 != 3) {
                        H0.a.e0(i6, parcel);
                    } else {
                        bundleI3 = H0.a.i(i6, parcel);
                    }
                }
                H0.a.y(iI03, parcel);
                return new C0737a(iU6, iU7, bundleI3);
            case 3:
                int iI04 = H0.a.i0(parcel);
                String strQ2 = null;
                GoogleSignInOptions googleSignInOptions = null;
                while (parcel.dataPosition() < iI04) {
                    int i7 = parcel.readInt();
                    char c8 = (char) i7;
                    if (c8 == 2) {
                        strQ2 = H0.a.q(i7, parcel);
                    } else if (c8 != 5) {
                        H0.a.e0(i7, parcel);
                    } else {
                        googleSignInOptions = (GoogleSignInOptions) H0.a.o(parcel, i7, GoogleSignInOptions.CREATOR);
                    }
                }
                H0.a.y(iI04, parcel);
                return new SignInConfiguration(strQ2, googleSignInOptions);
            case 4:
                int iI05 = H0.a.i0(parcel);
                PendingIntent pendingIntent2 = null;
                int iU8 = 0;
                int iU9 = 0;
                String strQ3 = null;
                while (parcel.dataPosition() < iI05) {
                    int i8 = parcel.readInt();
                    char c9 = (char) i8;
                    if (c9 == 1) {
                        iU8 = H0.a.U(i8, parcel);
                    } else if (c9 == 2) {
                        iU9 = H0.a.U(i8, parcel);
                    } else if (c9 == 3) {
                        pendingIntent2 = (PendingIntent) H0.a.o(parcel, i8, PendingIntent.CREATOR);
                    } else if (c9 != 4) {
                        H0.a.e0(i8, parcel);
                    } else {
                        strQ3 = H0.a.q(i8, parcel);
                    }
                }
                H0.a.y(iI05, parcel);
                return new C0771b(iU8, iU9, pendingIntent2, strQ3);
            default:
                int iI06 = H0.a.i0(parcel);
                long jW2 = -1;
                int iU10 = 0;
                String strQ4 = null;
                while (parcel.dataPosition() < iI06) {
                    int i9 = parcel.readInt();
                    char c10 = (char) i9;
                    if (c10 == 1) {
                        strQ4 = H0.a.q(i9, parcel);
                    } else if (c10 == 2) {
                        iU10 = H0.a.U(i9, parcel);
                    } else if (c10 != 3) {
                        H0.a.e0(i9, parcel);
                    } else {
                        jW2 = H0.a.W(i9, parcel);
                    }
                }
                H0.a.y(iI06, parcel);
                return new C0773d(jW2, strQ4, iU10);
        }
    }

    @Override // android.os.Parcelable.Creator
    public final /* synthetic */ Object[] newArray(int i4) {
        switch (this.f6693a) {
            case 0:
                return new C0699a[i4];
            case 1:
                return new C0700b[i4];
            case 2:
                return new C0737a[i4];
            case 3:
                return new SignInConfiguration[i4];
            case 4:
                return new C0771b[i4];
            default:
                return new C0773d[i4];
        }
    }
}
