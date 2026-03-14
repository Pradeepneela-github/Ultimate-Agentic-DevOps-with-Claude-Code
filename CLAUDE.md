# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple **static HTML/CSS portfolio website** built using HTML and CSS and it's for the DevOps Micro Internship (DMI) Week 1 program. The primary goal of the project is to showcase personal information, projects, and skills through a clean and responsive web interface. The website is intentionally kept lightweight and easy to maintain by avoiding JavaScript frameworks or complex dependencies.


The site can be deployed as a static website using services such as AWS S3 and CloudFront or any other static hosting platform.


**Purpose**: Template portfolio website deployed on Ubuntu + Nginx, kept live for 24 hours as proof of ownership and DevOps capability.

## File Structure

```
├── index.html          # Main homepage (80+ lines, includes navbar, hero, sections)
├── privacy.html        # Privacy policy page
├── terms.html          # Terms of service page
├── style.css           # Unified stylesheet for all pages (~500+ lines)
├── images/             # Static assets (logo, profile, course icons, signatures)
│   ├── logo.png
│   ├── profile.jpg
│   ├── Devops.jpg
│   ├── Git.jpg
│   ├── awsCloud.jpg
│   └── dmi-course.jpg
└── README.md           # Project overview and deployment instructions
```
The project does not include a backend server, database, or client-side frameworks.

## Common Development Conventions
The following conventions should be followed when working on this project:

- Use only HTML and CSS for implementation.
- Do not introduce JavaScript or any frontend frameworks.
- Keep the layout simple, clean, and responsive.
- Follow a mobile-first CSS design approach.
- Use semantic HTML elements where possible.
- Maintain consistent indentation and readable code formatting.

## Technology Restrictions
This project is intentionally designed to remain a static website.

The following technologies must NOT be added:

- React
- Vue
- Angular
- Next.js
- Any other JavaScript framework or library

All functionality should be implemented using plain HTML and CSS only.

## Asset Organization
To keep the project organized:

- All images must be stored in the `images/` folder.
- CSS files should remain inside the styling directory.
- File names should be clear and descriptive.
- Avoid adding unnecessary files or dependencies.

### Local Preview
To preview the site locally without deployment, use Python's built-in server:
```bash
python3 -m http.server 8000
```
Then open `http://localhost:8000` in a browser. The site will load with all styles and images intact.

### Editing Content
- **Main content**: Edit `index.html` (navigation, hero section, course cards, contact form)
- **Styling**: Edit `style.css` (responsive design, navbar, sections)
- **Supporting pages**: Edit `privacy.html` and `terms.html` as needed
- **Images**: Add/replace files in the `images/` directory and update `src` attributes in HTML

### Validation Before Deployment
- Open each page (`index.html`, `privacy.html`, `terms.html`) in a browser to verify layout and images load correctly
- Check mobile responsiveness by resizing the browser or using browser dev tools (F12)
- Ensure all external links (Font Awesome CDN, University/Blog links) are accessible
- Test navigation (anchor links, hamburger menu on mobile)

## Critical Requirement: Ownership Proof

**This is a mandatory DMI requirement.** Before deploying, you MUST edit the footer in `index.html` to add your deployment details. Find the footer section and add:

```html
<p><strong>Deployed by:</strong> [Your Name] | [Group/Cohort] | [Date]</p>
```

This proof must be visible in the browser screenshot submitted as evidence of deployment ownership.

## Deployment Context

This site is typically deployed using:
- **OS**: Ubuntu VM
- **Web Server**: Nginx
- **Access**: `http://<public-ip>`
- **Nginx Config**: Place the repo files in `/var/www/html` or equivalent, configure Nginx to serve `index.html`

No special backend setup or database is required.

## Architecture Notes

- **Single-page structure**: `index.html` uses anchor links (`#home`, `#book`, `#courses`, etc.) for section navigation
- **Responsive design**: CSS uses flexbox and media queries for mobile/tablet/desktop views
- **External dependencies**: Only Font Awesome (CDN-loaded) for icons; no npm/build tooling
- **Mobile menu**: Hamburger menu implemented via JavaScript (`toggleMenu()` function in index.html)
- **Fixed navbar**: Navbar stays at top while scrolling (position: fixed)

## Git Workflow

- Main branch: `main`
- Typical changes: Edit HTML/CSS, commit with clear messages describing what was customized
- No CI/CD pipeline—manual deployment to VM required

## Key Files for Future Changes

- **Quick content updates**: `index.html` (lines with course descriptions, links, contact info)
- **Quick styling fixes**: `style.css` (search for relevant selectors like `.navbar`, `.hero`, `.card`)
- **Footer/signature area**: Search `index.html` for the footer section to add ownership proof
